package TeaTime::CLI::Dispatcher;

use 5.12.1;

use TeaTime::Schema;

my $schema = TeaTime::Schema->connect('dbi:SQLite:dbname=.teadb');
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
         $tea_rs->create({
            name => $args->[1],
            enabled => 1,
         })
      }
      when ('list') {
         given ($args->[1]) {
            when ('teas') {
               say $_->name for $tea_rs->search({
                  enabled => 1
               }, {
                  order_by => 'name'
               })->all
            }
            when ('times') {
               say sprintf '%s: %s', $_->when_occured->ymd, $_->tea->name
                  for $tea_time_rs->search(undef, {
                     prefetch => 'tea',
                     order_by => 'when_occured'
                  })->all
            }
            default { say 'you need to list teas or list times!'; exit 1 }
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
