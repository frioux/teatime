package TeaTime::Command::new_milk;

use 5.20.0;
use Moo;
use experimental 'signatures';

extends 'TeaTime::Command';

sub abstract { 'add new milk for expiration date tracking' }

sub usage_desc { 't new_milk <expiration_date>' }

sub validate_args ($self, $opt, $args) {
  $self->usage_error('too few arguments') unless scalar @$args >= 1;

  $self->usage_error('date must be formatted YYYY-MM-DD')
    unless $args->[0] =~ /^\d{4}-\d{2}-\d{2}$/;
}

sub execute ($self, $opt, $args) {
  $self->app->schema->resultset('Milk')->create({ when_expires => "$args->[0] 00:00:00" });

  say "creating milk expiration date for $args->[0]";
}

1;
