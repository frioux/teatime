package TeaTime::Command::message;

use 5.20.0;
use Moo;
use experimental 'signatures', 'postderef';

extends 'TeaTime::Command';

sub abstract { 'send message' }

sub usage_desc { 't message <message>' }

sub validate_args ($self, $opt, $args) {
  $self->usage_error('too few arguments') unless scalar @$args >= 1;
}

sub execute ($self, $, $args) { $self->app->send_message(join q( ), $args->@*) }

1;

