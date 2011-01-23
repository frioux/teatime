package TeaTime;

use 5.12.1;
use Moo;

extends 'App::Cmd';

use TeaTime::Web::API;
use TeaTime::Util 'config';

has api => (
   is => 'ro',
   default => sub {
      TeaTime::Web::API->new(
         username => config->{cli}{username},
         password => config->{cli}{password},
      )
   },
);

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
         for (map $_->{jid}, grep $_->{enabled}, @{$self->api->get_contacts}) {
            $cl->send_message($message, $_) if config->{send_messages};
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

1;
