package TeaTime::Command::new_milk;

use 5.20.0;
use Moo;

extends 'TeaTime::Command';

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

  $self->app->schema->resultset('Milk')->create({ when_expires => "$args->[0] 00:00:00" });

  say "creating milk expiration date for $args->[0]";
}

1;
