package TeaTime::Command::create_tea;

use TeaTime -command;

use 5.12.1;
use warnings;

sub abstract { 'create a new tea' }

sub usage_desc { "t create_tea <name> <steep-time> <is-heaping>" }

sub validate_args {
  my ($self, $opt, $args) = @_;

  $self->usage_error('too few arguments') unless scalar @$args >= 2;

  $self->usage_error('steep-time is should be in seconds') unless $args->[1] =~ /^\d+$/;
}
sub execute {
  my ($self, $opt, $args) = @_;

  $self->app->api->add_tea( $args->[0], $args->[1], $args->[2] );

  say "created $args->[0]";
}

1;
