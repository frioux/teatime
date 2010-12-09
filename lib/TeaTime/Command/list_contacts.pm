package TeaTime::Command::list_contacts;

use TeaTime -command;

use 5.12.1;
use warnings;

sub abstract { 'print a list of contacts' }

sub execute {
  my ($self, $opt, $args) = @_;

  my $x = 0;
  print map ++$x . '. ' . $_ . "\n", $self->app->contact_rs->get_column('jid')->all
}

1;
