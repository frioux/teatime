package TeaTime::Command::toggle_contact;

use 5.20.0;
use Moo;
use experimental 'signatures';

extends 'TeaTime::Command';

sub abstract { 'toggle contact' }

sub usage_desc { 't toggle_contact <contact>' }

sub execute ($self, $opt, $args) {
  $self->app->single_item(sub ($s) {
     say 'Toggling ' . $_[0]->jid . ' to ' . ($s->enabled?'disabled':'enabled');
     $s->toggle->update;
  }, 'contact', $args->[0], $self->app->contact_rs);
}

1;
