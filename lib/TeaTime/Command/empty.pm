package TeaTime::Command::empty;

use TeaTime -command;

use 5.12.1;
use warnings;

sub execute {
  my ($self, $opt, $args) = @_;

   $self->app->tea_time_rs->in_order->first->events->create({
      type => { name => 'Pot Empty' }
   })
}

1;
