package TeaTime::CLI::Dispatcher;

use 5.12.1;

use Path::Dispatcher::Declarative -base;
use TeaTime::Schema;

chdir '~';
my $schema = TeaTime::Schema->connect('dbi:SQLite:dbname=.teadb');
my $tea_rs = $schema->resultset('Tea');
my $tea_time_rs = $schema->resultset('TeaTime');

on init => sub { $schema->deploy unless -e '.teadb' };

on [set => qr/^\w+$/] => sub {
   $tea_time_rs->create({ tea => { name => $2 } })
};

on [create => qr/^\w+$/] => sub { $tea_rs->create({ name => $2, enabled => 1 }) };

under list => sub {
   on 'teas' => sub {
      say $_ for $tea_rs->search({ enabled => 1 }, { order_by => 'name' })
         ->get_column('name')->all
   };

   on 'times' => sub {
      say $_->when_occured->ymd . ': ' . $_->tea->name
         for $tea_time_rs->search(undef, {
            prefetch => 'tea',
            order_by => 'when_occured'
         })->all
   };
};
on [update => '*', '*'] => sub {
   $tea_rs->search({ name => $2 })->update({ name => $3 })
};

on [toggle => qr/^\w+$/] => sub {
   $tea_rs->single({ name => $2 })->toggle->update
};

1;
