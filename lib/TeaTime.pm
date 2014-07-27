package TeaTime;

use 5.20.0;
use Moo;

extends 'App::Cmd';

use TeaTime::Schema;
use JSON;
use FindBin '$Bin';
use List::Util 'first';
use File::HomeDir;

sub config {
   state $config = decode_json(do {
     my $f = '.teatime.json';
     local( @ARGV, $/ ) =  first { -f $_ } "$Bin/$f", home()."/$f", $f; <>
   });

   $config->{send_messages} //= exists $ENV{TXMPP} ? $ENV{TXMPP} : 1;

   $config->{writable_db}   //= exists $ENV{TDB}   ? $ENV{TDB}   : 1;

   $config
}

my $schema = TeaTime::Schema->connect({
   dsn      => config->{db},
   writable => config->{writable_db},
});

my $tea_rs = $schema->resultset('Tea');
my $tea_time_rs = $schema->resultset('TeaTime');
my $contact_rs = $schema->resultset('Contact');

sub schema { $schema }
sub tea_rs { $tea_rs }
sub tea_time_rs { $tea_time_rs }
sub contact_rs { $contact_rs }

sub single_item {
   my ($self, $action, $name, $arg, $rs) = @_;

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
   my ($self, $message) = @_;
   require AnyEvent;
   require AnyEvent::XMPP::Client;

   my $passed_j = $_[2];
   my $j;
   $j = AnyEvent->condvar unless $passed_j;
   my $cl = AnyEvent::XMPP::Client->new();
   $cl->add_account(
     config->{xmpp}{jid}, config->{xmpp}{password}, config->{xmpp}{server},
     undef, { dont_retrieve_roster => 1 }
   );
   $cl->reg_cb (
      session_ready => sub {
         for ($contact_rs->enabled->get_column('jid')->all) {
            $cl->send_message($message, $_)
               if $self->config->{send_messages};
            say "Sending $message to $_";
         }
         $cl->reg_cb(send_buffer_empty => sub { $cl->disconnect });
      },
      disconnect => sub { if ($passed_j) { $passed_j->send } else { $j->send } },
      error => sub { say "ERROR: " . $_[2]->string },
   );
   $cl->start;
   $j->recv unless $passed_j;
}

sub _plugins {
   "TeaTime::Command::create_contact",
   "TeaTime::Command::create_tea",
   "TeaTime::Command::empty",
   "TeaTime::Command::event",
   "TeaTime::Command::init",
   "TeaTime::Command::list_contacts",
   "TeaTime::Command::list_teas",
   "TeaTime::Command::list_times",
   "TeaTime::Command::message",
   "TeaTime::Command::new_milk",
   "TeaTime::Command::server",
   "TeaTime::Command::set_tea",
   "TeaTime::Command::timer",
   "TeaTime::Command::toggle_contact",
   "TeaTime::Command::toggle_tea",
   "TeaTime::Command::undo",
   "TeaTime::Command::weekday_stats",
}

1;
