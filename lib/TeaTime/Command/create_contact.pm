package TeaTime::Command::create_contact;

use TeaTime -command;

use 5.12.1;
use warnings;

sub abstract { 'create a new contact' }

sub execute {
  my ($self, $opt, $args) = @_;

  $self->app->contact_rs->create({
    jid => $args->[0],
    enabled => 1,
  })
}

1;
