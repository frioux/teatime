package TeaTime::Schema::ResultSet::Event;

use parent 'DBIx::Class::ResultSet';

__PACKAGE__->load_components(qw(
   Helper::ResultSet::IgnoreWantarray
));

sub chosen {
   shift->search({
      'type.name' => 'Chose Tea',
   }, {
      join => 'type',
   })
}

1;

