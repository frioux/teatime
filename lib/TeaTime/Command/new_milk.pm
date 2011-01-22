package TeaTime::Command::new_milk;

use TeaTime -command;

use 5.12.1;
use warnings;

sub abstract { 'add new milk for expiration date tracking' }

sub usage_desc { 't new_milk <expiration_date>' }

sub validate_args {
  my ($self, $opt, $args) = @_;

  $self->usage_error('too few arguments') unless scalar @$args >= 1;

  $self->usage_error('date must be formatted YYYY-MM-DD')
    unless $args->[0] =~ /^\d{4}-\d{2}-\d{2}$/;
}

sub execute {
  my ($self, $opt, $args) = @_;

  $self->app->api->add_milk($args->[0]);

  say "creating milk expiration date for $args->[0]";
}

1;
