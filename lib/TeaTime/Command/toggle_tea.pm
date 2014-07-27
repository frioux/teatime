package TeaTime::Command::toggle_tea;

use 5.20.0;
use Moo;
use experimental 'signatures';

extends 'TeaTime::Command';

sub abstract { 'toggle tea' }

sub usage_desc { 't toggle_tea <tea>' }

sub execute ($self, $opt, $args) {
  $self->app->single_item(sub ($s) {
     say 'Toggling ' . $s->name . ' to ' . ($s->enabled?'disabled':'enabled');
     $s->toggle->update;
  }, 'tea', $args->[0], $self->app->tea_rs);
}

1;
