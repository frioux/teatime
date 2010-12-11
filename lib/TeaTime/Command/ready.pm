package TeaTime::Command::ready;

use TeaTime -command;

use 5.12.1;
use warnings;

sub abstract { 'mark pot as ready' }

sub execute {
  my ($self, $opt, $args) = @_;

  my $tea_time = $self->app->tea_time_rs->in_order->first;

  $tea_time->events->create({
    type => { name => 'Ready' }
  });
  $self->app->send_message(
    sprintf 'Tea ready: %s (%s) (%s)',
      $tea_time->tea->name,
      $self->app->config->{servers}{api},
      $self->app->config->{servers}{human}
  );
}

1;
