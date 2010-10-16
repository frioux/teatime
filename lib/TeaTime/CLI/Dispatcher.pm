package TeaTime::CLI::Dispatcher;

use 5.12.1;

use TeaTime::Schema;

my $schema = TeaTime::Schema->connect('dbi:SQLite:dbname=.teadb');
my $tea_rs = $schema->resultset('Tea');
my $tea_time_rs = $schema->resultset('TeaTime');

sub single_tea {
   my ($action, $name, $tea_rs) = @_;

   my $teas = $tea_rs->cli_find($name);
   my $count = $teas->count;
   if ($count > 1) {
      say 'More than one tea found:';
      my $x = 0;
      print join '', map sprintf("%2d. %s\n", ++$x, $_->name), $teas->all;
      exit 1;
   } elsif ($count == 1) {
      $action->($teas->single)
   } else {
      say "No tea with with name «$name» found";
      exit 1;
   }
}

sub dispatch {
   my $args = $_[1];
   given ($args->[0]) {
      when ('init') {
         $schema->deploy
      }
      when ('set') {
         single_tea(sub {
            say 'Setting tea to ' . $_[0]->name;
            $tea_time_rs->create({ tea_id => $_[0]->id })
         }, $args->[1], $tea_rs->enabled);
      }
      when ('clear') {
         $tea_rs->delete; $tea_time_rs->delete
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
         $tea_rs->create({
            name => $args->[1],
            enabled => 1,
         })
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
            default { say 'you need to list teas or list times!'; exit 1 }
         }
      }
      when ('toggle') {
         single_tea(sub {
            say 'Toggling ' . $_[0]->name . ' to ' . ($_[0]->enabled?'disabled':'enabled');
            $_[0]->toggle->update;
         }, $args->[1], $tea_rs);
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
 perl teatime init|set $tea|clear|create $tea|list|toggle $tea|server
USAGE
      }
   }
}

1;
