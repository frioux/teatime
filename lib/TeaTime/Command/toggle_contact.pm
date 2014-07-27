package TeaTime::Command::toggle_contact;

use 5.20.0;
use Moo;

extends 'TeaTime::Command';

sub abstract { 'toggle contact' }

sub usage_desc { 't toggle_contact <contact>' }

sub execute {
  my ($self, $opt, $args) = @_;

  $self->app->single_item(sub {
     say 'Toggling ' . $_[0]->jid . ' to ' . ($_[0]->enabled?'disabled':'enabled');
     $_[0]->toggle->update;
  }, 'contact', $args->[0], $self->app->contact_rs);
}

1;
