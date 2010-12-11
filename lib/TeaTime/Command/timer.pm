package TeaTime::Command::timer;
use TeaTime -command;

use 5.12.1;
use warnings;

sub abstract { 'run timer for last set tea' }

sub usage_desc { 't timer [time]' }

sub execute {
  my ($self, $opt, $args) = @_;

  my $tea_time_rs = $self->app->tea_time_rs;

  my $seconds = $args->[0] || $tea_time_rs->in_order->first->tea->steep_time;

  $tea_time_rs->in_order->first->events->create({
     type => { name => 'Started Steep' }
  });

  $|++; # print immediately, not after a newline
  require AnyEvent;
  my $j = AnyEvent->condvar;
  my $once;
  my $x;
  my $w; $w = AnyEvent->timer (
     interval => 1,
     cb       => sub {
        print "\r\x1b[J" . $seconds--;
        if ($seconds < 0 && !$once) {
           use Term::ReadKey;
           ReadMode 4; # Turn off controls keys
           print "\a"; # BEEP
           1 while !defined ReadKey(-1);
           ReadMode 0; # Reset tty mode before exiting
           $tea_time_rs->in_order->first->events->create({
              type => { name => 'Stopped Steep' }
           });
           $j->broadcast
        }
     }
  );
  $j->wait;
}

1;
