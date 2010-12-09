package TeaTime;

use App::Cmd::Setup -app;

use 5.12.1;
use warnings;

use TeaTime::Schema;
use FindBin;

my $schema = TeaTime::Schema->connect("dbi:SQLite:dbname=$FindBin::Bin/../.teadb");
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

1;
