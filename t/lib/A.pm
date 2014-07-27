package A;

use 5.20.0;
use warnings;

use experimental 'signatures';

use Data::Dumper::Concise;
use Test::More;
use Test::Deep;

use Sub::Exporter::Progressive -setup => {
   exports => [qw(app stdout_is)],
   groups  => {
      default => [qw( app stdout_is )],
   },
};

sub stdout_is ($result, $expected, $reason = undef) {
   my @out = split /\n/, $result->stdout;
   local $Test::Builder::Level = $Test::Builder::Level + 1;
   is_deeply(\@out, $expected, $reason || ())
     or diag(
      Dumper({
            stdout => \@out,
            stderr => [split /\n/, $result->stderr],
            error  => $result->error,
         }))
}

sub app {
   require TeaTime;

   my $app = TeaTime->new({
      connect_info => {
         dsn => 'dbi:SQLite::memory:',
         writable => 1,
      },
   });

   my $s = $app->schema;

   A->_deploy_schema($s);
   A->_populate_schema($s);

   $app
}

sub _deploy_schema ($, $schema) { $schema->deploy }

sub _populate_schema ($, $schema) { }

1;
