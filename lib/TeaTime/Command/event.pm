package TeaTime::Command::event;

use 5.20.0;
use Moo;
use experimental 'signatures';

extends 'TeaTime::Command';

sub abstract { 'mark pot with arbitrary event' }

sub usage_desc { 't event <event-name>' }

sub validate_args ($self, $opt, $args) {
  $self->usage_error('too few arguments') unless scalar @$args == 1;
}

sub execute ($self, $opt, $args) {
   $self->app->tea_time_rs->in_order->first->events->create({
      type => { name => $args->[0] }
   });

   say "Adding event «$args->[0]» to pot";
}

1;

