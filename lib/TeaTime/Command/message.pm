package TeaTime::Command::message;

use TeaTime -command;

use 5.12.1;
use warnings;

sub abstract { 'send message' }

sub usage_desc { 't message <message>' }

sub validate_args {
  my ($self, $opt, $args) = @_;

  $self->usage_error('too few arguments') unless scalar @$args == 1;
}

sub execute { $_[0]->app->send_message($_[2]->[0]) }

1;

