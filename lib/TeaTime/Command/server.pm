package TeaTime::Command::server;

use 5.20.0;
use Moo;

extends 'TeaTime::Command';

use FindBin;

sub abstract { 'run tea server' }

sub execute {
  my ($self, $opt, $args) = @_;

  require Plack::Runner;
  my $runner = Plack::Runner->new(
     server => 'Starman', env => 'deployment'
  );
  my @args = (
    "$FindBin::Bin/../lib/TeaTime/Web.pm",
    '-I', "$FindBin::Bin/../lib",
    '-D',
    '-p', 8320,
    '-o', $self->app->config->{web_server}{listen_on},
  );
  $runner->parse_options(@args);
  $runner->set_options(argv => \@args);
  $runner->run;
}

1;
