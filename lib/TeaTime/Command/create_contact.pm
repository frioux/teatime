package TeaTime::Command::create_contact;

use TeaTime -command;

use 5.12.1;
use warnings;

sub abstract { 'create a new contact' }

sub usage_desc { 't create_contact <contact>' }

sub validate_args {
  my ($self, $opt, $args) = @_;

  $self->usage_error('you forgot to pass a new contact!') unless @$args;
}

sub execute {
  my ($self, $opt, $args) = @_;

  $self->app->api->add_contact( $args->[0] );

  say "created $args->[0]";
}

1;
