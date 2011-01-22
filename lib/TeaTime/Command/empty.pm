package TeaTime::Command::empty;

use TeaTime -command;

use 5.12.1;
use warnings;

sub abstract { 'mark pot as empty' }

sub execute {
  my ($self, $opt, $args) = @_;

   $self->app->api->add_event('Pot Empty');

   say 'Marking pot as empty';
}

1;
