package TeaTime::Command::create_contact;

use 5.20.0;
use Moo;
use experimental 'signatures';

extends 'TeaTime::Command';

sub abstract { 'create a new contact' }

sub usage_desc { 't create_contact <contact>' }

sub validate_args ($self, $opt, $args) {
  $self->usage_error('you forgot to pass a new contact!') unless @$args;
}

sub execute ($self, $opt, $args) {
  $self->app->contact_rs->create({
    jid => $args->[0],
    enabled => 1,
  });

  say "created $args->[0]";
}

1;
