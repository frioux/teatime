package TeaTime::Command::timer;
use TeaTime -command;

use 5.12.1;
use warnings;

sub abstract { 'run timer for last set tea' }

sub usage_desc { 't timer [time]' }

sub execute {
  my ($self, $opt, $args) = @_;

  my $tea_time = $self->app->api->get_current_tea_time;

  my $seconds = $args->[0] || $tea_time->{prescribed_steep_time};

  $self->app->api->add_event('Started Steep');

  $|++; # print immediately, not after a newline
  require AnyEvent;
  my $j = AnyEvent->condvar;
  my $once = 0;
  my $w = AnyEvent->timer (
     interval => 1,
     cb       => sub {
        if ($seconds >= 0) {
           print "\r\x1b[J" . $seconds--;
        } elsif (!$once) {
           use Term::ReadKey;
           ReadMode 4; # Turn off controls keys
           print "\a"; # BEEP
           1 while !defined ReadKey(-1);
           ReadMode 0; # Reset tty mode before exiting
           $self->app->api->add_event('Stopped Steep');
           $self->app->api->add_event('Ready');
           $self->app->send_message(
             (sprintf 'Tea ready: %s (%s) (%s)',
               $tea_time->{name},
               $self->app->config->{servers}{api},
               $self->app->config->{servers}{human}
             ),
             $j
           );
           $once = 1
        }
     }
  );
  $j->recv;
}

1;
