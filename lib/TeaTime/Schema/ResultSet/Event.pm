package TeaTime::Schema::ResultSet::Event;

use parent 'TeaTime::Schema::ResultSet';

sub chosen {
   shift->search({
      'type.name' => 'Chose Tea',
   }, {
      join => 'type',
   })
}

1;

