package TeaTime::Command::message;

use 5.20.0;
use Moo;

extends 'TeaTime::Command';

sub abstract { 'send message' }

sub usage_desc { 't message <message>' }

sub validate_args {
  my ($self, $opt, $args) = @_;

  $self->usage_error('too few arguments') unless scalar @$args >= 1;
}

sub execute { $_[0]->app->send_message(join q( ), @{$_[2]}) }

1;

