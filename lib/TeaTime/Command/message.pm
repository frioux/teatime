package TeaTime::Command::message;

use TeaTime -command;

use 5.12.1;
use warnings;

sub abstract { 'send message' }

sub usage_desc { 't message <message>' }

sub validate_args {
  my ($self, $opt, $args) = @_;

  $self->usage_error('too few arguments') unless scalar @$args >= 1;
}

sub execute {
   require IO::Async::Loop;
   my $loop = IO::Async::Loop->new;
   $_[0]->app->send_message((join q( ), @{$_[2]}), $loop);
   $loop->run
}

1;

