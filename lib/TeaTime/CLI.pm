package TeaTime::CLI;

use 5.12.1;

use TeaTime::Schema;
use FindBin;

my $schema = TeaTime::Schema->connect("dbi:SQLite:dbname=$FindBin::Bin/../.teadb");
my $tea_rs = $schema->resultset('Tea');
my $tea_time_rs = $schema->resultset('TeaTime');
my $contact_rs = $schema->resultset('Contact');
my $event_type_rs = $schema->resultset('EventType');
use List::Util 'sum';

sub single_item {
   my ($action, $name, $arg, $rs) = @_;

   $rs = $rs->cli_find($arg);
   my $count = $rs->count;
   if ($count > 1) {
      say "More than one $name found:";
      my $x = 0;
      print join '', map sprintf("%2d. %s\n", ++$x, $_->view), $rs->all;
      exit 1;
   } elsif ($count == 1) {
      $action->($rs->single)
   } else {
      say "No $name «$arg» found";
      exit 1;
   }
}

sub send_message {
   my $message = shift;
   require AnyEvent;
   require AnyEvent::XMPP::Client;

   my $j = AnyEvent->condvar;
   my $cl = AnyEvent::XMPP::Client->new();
   $cl->add_account('frioux@gmail.com', 'password', 'talk.google.com', undef, { dont_retrieve_roster => 1 });
   $cl->reg_cb (
      session_ready => sub {
         for ($contact_rs->enabled->get_column('jid')->all) {
            $cl->send_message($message, $_);
            say "Sending $message to $_";
         }
         $cl->reg_cb(send_buffer_empty => sub { $cl->disconnect });
      },
      disconnect => sub { $j->broadcast },
      error => sub { say "ERROR: " . $_[2]->string },
   );
   $cl->start;
   $j->wait;
}

sub dispatch {
   my $args = $_[1];
   given ($args->[0]) {
      when ('init') {
         given ($args->[1]) {
            when (2) {
               $schema->deploy({ sources => ['Contact'] })
            }
            when (3) {
               $schema->deploy({ sources => [qw(Event EventType)] });
               my $id = $event_type_rs->cli_find('chose')->first->id;
               my $rs = $tea_time_rs->search(undef, {
                  '+select' => 'when_occured',
                  '+as' => 'when',
               });
               for ($rs->all) {
                  $_->add_to_events({
                     type_id => $id,
                     when_occurred => $_->get_column('when'),
                  });
               }
            }
            default { $schema->deploy }
         }
      }
      when ('set') {
         given ($args->[1]) {
            when ('tea') {
               single_item(sub {
                  say 'Setting tea to ' . $_[0]->name;
                  $tea_time_rs->create({ tea_id => $_[0]->id })
               }, 'tea', $args->[2], $tea_rs->enabled);
            }
            when ('event') {
               single_item(sub {
                  say 'Setting event to ' . $_[0]->name;
                  $tea_time_rs->in_order->first->add_to_events({ type_id => $_[0]->id })
               }, 'event', $args->[2], $event_type_rs);
            }
            default { say 'you must set tea or set event!'; exit 1 }
         }
      }
      when ('undo') {
         my $t = $tea_time_rs->search(undef, {
            order_by => { -desc => 'when_occured' }
         })->first;
         if ($args->[1]) {
            say 'undoing last tea time: ' . $t->when_occured->ymd . ', ' . $t->tea->name;
            $t->delete;
         } else {
            say 'would undo last tea time: ' . $t->when_occured->ymd . ', ' . $t->tea->name;
         }
      }
      when ('create') {
         given ($args->[1]) {
            when ('tea') {
               $tea_rs->create({
                  name => $args->[2],
                  enabled => 1,
               })
            }
            when ('contact') {
               $contact_rs->create({
                  jid => $args->[2],
                  enabled => 1,
               })
            }
            when ('event') {
               $event_type_rs->create({ name => $args->[2] })
            }
            default { say 'you need to create tea or create contact!'; exit 1 }
         }
      }
      when ('rand') {
         say $tea_rs->enabled->rand->single->name;
      }
      when ('most-rand') {
         my @teas = $tea_time_rs->search({ 'tea.enabled' => 1 })->stats->all;
         @teas = map { ($_) x $_->{count} } @teas;
         say $teas[rand @teas]->{name};
      }
      when ('least-rand') {
         my @teas = $tea_time_rs->search({ 'tea.enabled' => 1 })->stats->all;
         my $lcm = multilcm(map $_->{count}, @teas);
         @teas = map { ($_) x ($lcm/$_->{count}) } @teas;
         say $teas[rand @teas]->{name};
      }
      when ('ready') {
         $tea_time_rs->in_order->first->events->create({
            type => { name => 'Ready' }
         });
         send_message('Tea ready: ' . $tea_time_rs->in_order->first->tea->name .
            ' (http://valium.lan.mitsi.com:8320)');
      }
      when ('list') {
         given ($args->[1]) {
            when ('teas') {
               my $x = 0;
               print join '', map sprintf("%2d. %s\n", ++$x, $_->name),
                  $tea_rs->search(undef, { order_by => 'name' })->all
            }
            when ('times') {
               say sprintf '%s: %s', $_->when_occured->ymd, $_->tea->name
                  for $tea_time_rs->search(undef, {
                     prefetch => 'tea',
                     order_by => 'when_occured'
                  })->all
            }
            when ('contacts') {
               my $x = 0;
               print map ++$x . '. ' . $_ . "\n", $contact_rs->get_column('jid')->all
            }
            when ('events') {
               my $x = 0;
               print map ++$x . '. ' . $_ . "\n", $event_type_rs->get_column('name')->all
            }
            default { say 'you need to list teas or list times or list contacts!'; exit 1 }
         }
      }
      when ('toggle') {
         given ($args->[1]) {
            when ('tea') {
               single_item(sub {
                  say 'Toggling ' . $_[0]->name . ' to ' . ($_[0]->enabled?'disabled':'enabled');
                  $_[0]->toggle->update;
               }, 'tea', $args->[2], $tea_rs);
            }
            when ('contact') {
               single_item(sub {
                  say 'Toggling ' . $_[0]->jid . ' to ' . ($_[0]->enabled?'disabled':'enabled');
                  $_[0]->toggle->update;
               }, 'contact', $args->[2], $contact_rs);
            }
            default { say 'you need to toggle tea or toggle contact!'; exit 1 }
         }
      }
      when ('server') {
         require Plack::Runner;
         my $runner = Plack::Runner->new(
            server => 'Starman', env => 'deployment'
         );
         my @args = ('lib/TeaTime/Web.pm', '-D', '-p', 8320, '-o', 'valium.lan.mitsi.com');
         $runner->parse_options(@args);
         $runner->set_options(argv => \@args);
         $runner->run;
      }
      default {
         print <<'USAGE';
 perl teatime init|set $tea|clear|create $tea|list|toggle $tea|server|rand|undo
USAGE
      }
   }
}

# http://www.perlmonks.org/?node_id=56906
sub gcf {
  my ($x, $y) = @_;
  ($x, $y) = ($y, $x % $y) while $y;
  return $x;
}

sub lcm {
  return($_[0] * $_[1] / gcf($_[0], $_[1]));
}

sub multigcf {
  my $x = shift;
  $x = gcf($x, shift) while @_;
  return $x;
}

sub multilcm {
  my $x = shift;
  $x = lcm($x, shift) while @_;
  return $x;
}

1;
