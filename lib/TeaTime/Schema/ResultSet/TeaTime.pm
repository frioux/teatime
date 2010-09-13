package TeaTime::Schema::ResultSet::TeaTime;

use parent 'DBIx::Class::ResultSet';

sub in_order { $_[0]->search(undef, { order_by => { -desc => 'when_occured' } }) }

sub format {
   $_[0]->search(undef, {
      join         => 'tea',
      select       => [qw(when_occured tea.name)],
      as           => [qw(when name)],
      result_class => 'DBIx::Class::ResultClass::HashRefInflator',
   })
}

sub stats {
   $_[0]->search(undef, {
      join         => 'tea',
      group_by     => 'tea.name',
      select       => [qw(tea.name), { count => 'tea.name' }],
      as           => [qw(name count)],
      result_class => 'DBIx::Class::ResultClass::HashRefInflator',
   })
}

1;
