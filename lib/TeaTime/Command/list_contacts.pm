package TeaTime::Command::list_contacts;

use 5.20.0;
use Moo;
use experimental 'signatures';

extends 'TeaTime::Command';

sub abstract { 'print a list of contacts' }

sub execute ($self, $opt, $args) {
  my $x = 0;
  print map ++$x . '. ' . $_ . "\n", $self->app->contact_rs->get_column('jid')->all
}

1;
