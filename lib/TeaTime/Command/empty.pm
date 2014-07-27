package TeaTime::Command::empty;

use 5.20.0;
use Moo;
use experimental 'signatures';

extends 'TeaTime::Command';

sub abstract { 'mark pot as empty' }

sub execute ($self, $opt, $args) {
   $self->app->tea_time_rs->in_order->first->events->create({
      type => { name => 'Pot Empty' }
   })
}

1;
