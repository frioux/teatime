package TeaTime::Command::event;

use TeaTime -command;

use 5.12.1;
use warnings;

sub abstract { 'mark pot with arbitrary event' }

sub usage_desc { 't event <event-name>' }

sub validate_args {
  my ($self, $opt, $args) = @_;

  $self->usage_error('too few arguments') unless scalar @$args == 1;
}

sub execute {
  my ($self, $opt, $args) = @_;

   $self->app->api->add_event($args->[0]);

   say "Adding event «$args->[0]» to pot";
}

1;

