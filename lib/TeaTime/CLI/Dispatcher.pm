package TeaTime::CLI::Dispatcher;

use 5.12.1;

use KiokuDB;
use aliased 'TeaTime::Model::Instructions' => 'Instructions';
use TeaTime::Schema;

# {{{ KIOKU
my $dir    = KiokuDB->connect(
   'dbi:SQLite:dbname=.teadb',
   schema => 'TeaTime::Schema',
);
my $schema = $dir->backend->schema;
# }}}
my $tea_rs = $schema->resultset('Tea');
my $tea_time_rs = $schema->resultset('TeaTime');

sub dispatch {
   my $args = $_[1];
   given ($args->[0]) {
      when ('init') {
         $schema->deploy
      }
      when ('set') {
         $tea_time_rs->create({ tea => { name => $args->[1] } })
      }
      when ('clear') {
         $tea_rs->delete; $tea_time_rs->delete
      }
      when ('create') {
         # {{{ KIOKU
         $dir->txn_do(scope => 1, body => sub {
            $tea_rs->create({
               name => $args->[1],
               enabled => 1,
               metadata => Instructions->new({
                  time => $args->[2],
                  is_heaping => !!($args->[3])
               }),
            })
         });
         # }}}
      }
      when ('list') {
         given ($args->[1]) {
            when ('teas') {
               # {{{ KIOKU
               my $scope = $dir->new_scope;

               say $_->name . ($_->metadata->is_heaping?' heaping':'').' time: '.$_->metadata->time
               for $tea_rs->search({ enabled => 1 }, { order_by => 'name' })->all
               # }}}
            }
            when ('times') {
               say sprintf '%s: %s', $_->when_occured->ymd, $_->tea->name
                  for $tea_time_rs->search(undef, {
                     prefetch => 'tea',
                     order_by => 'when_occured'
                  })->all
            }
         }
      }
      when ('toggle') {
         $tea_rs->single({ name => $args->[1] })->toggle->update
      }
      when ('server') {
         require Plack::Runner;
         my $runner = Plack::Runner->new(
            server => 'Starman', env => 'deployment'
         );
         my @args = ('lib/TeaTime/Web.pm', '-D', '-p', 8320, '-o', 'valium.lan.mitsi.com');
         $runner->parse_options(@args);
         $runner->set_options(argv => \@args);
         $runner->run;
      }
   }
}

1;
