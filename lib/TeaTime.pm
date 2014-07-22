package TeaTime;

use App::Cmd::Setup -app;

use 5.12.1;
use warnings;

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
   my ($self, $message, $loop) = @_;
   require Net::Async::XMPP::Client;

   my $cl = Net::Async::XMPP::Client->new;

   $loop->add($cl);

   $cl->connect(
     host => config->{xmpp}{server},
     jid => config->{xmpp}{jid},
     password => config->{xmpp}{password},
     on_connected => sub {
       my $cl = shift;

       for ($contact_rs->enabled->get_column('jid')->all) {
          $cl->compose(
            to   => $_,
            body => $messge,
          )->send if $self->config->{send_messages};
          say "Sending $message to $_";
       }
       $cl->configure(on_write_finished => sub { $cl->disconnect; $loop->stop });
     },
   );
}

1;
