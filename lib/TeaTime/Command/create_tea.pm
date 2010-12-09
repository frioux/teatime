package TeaTime::Command::create_tea;

use TeaTime -command;

use 5.12.1;
use warnings;

sub execute {
  my ($self, $opt, $args) = @_;

  $self->app->tea_rs->create({
    name       => $args->[0],
    steep_time => $args->[1],
    heaping    => $args->[2],
    enabled    => 1,
  })
}

1;
