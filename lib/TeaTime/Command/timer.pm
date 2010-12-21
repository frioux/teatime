package TeaTime::Command::timer;
use TeaTime -command;

use 5.12.1;
use warnings;

sub abstract { 'run timer for last set tea' }

sub usage_desc { 't timer [time]' }

sub execute {
  my ($self, $opt, $args) = @_;

  my $tea_time = $self->app->tea_time_rs->in_order->first;

  my $seconds = $args->[0] || $tea_time->tea->steep_time;

  $tea_time->events->create({
     type => { name => 'Started Steep' }
  });

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
           $tea_time->events->create({
              type => { name => 'Stopped Steep' }
           });
           $tea_time->events->create({
             type => { name => 'Ready' }
           });
           $self->app->send_message(
             (sprintf 'Tea ready: %s (%s) (%s)',
               $tea_time->tea->name,
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
