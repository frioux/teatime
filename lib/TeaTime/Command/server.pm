package TeaTime::Command::server;

use TeaTime -command;

use FindBin;
use 5.12.1;
use warnings;

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
    '-o', 'valium.lan.mitsi.com'
  );
  $runner->parse_options(@args);
  $runner->set_options(argv => \@args);
  $runner->run;
}

1;
