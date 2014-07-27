package TeaTime::Command::toggle_tea;

use 5.20.0;
use Moo;

extends 'TeaTime::Command';

sub abstract { 'toggle tea' }

sub usage_desc { 't toggle_tea <tea>' }

sub execute {
  my ($self, $opt, $args) = @_;

  $self->app->single_item(sub {
     say 'Toggling ' . $_[0]->name . ' to ' . ($_[0]->enabled?'disabled':'enabled');
     $_[0]->toggle->update;
  }, 'tea', $args->[0], $self->app->tea_rs);
}

1;
