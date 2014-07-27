package TeaTime::Command::list_contacts;

use 5.20.0;
use Moo;

extends 'TeaTime::Command';

sub abstract { 'print a list of contacts' }

sub execute {
  my ($self, $opt, $args) = @_;

  my $x = 0;
  print map ++$x . '. ' . $_ . "\n", $self->app->contact_rs->get_column('jid')->all
}

1;
