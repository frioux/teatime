package TeaTime::Schema::ResultSet::TeaTime;

use parent 'DBIx::Class::ResultSet';
__PACKAGE__->load_components('Helper::ResultSet::IgnoreWantarray');

sub in_order { $_[0]->search(undef, { order_by => { -desc => 'when_occured' } }) }

sub stats {
   $_[0]->search(undef, {
      join         => 'tea',
      group_by     => 'tea.name',
      select       => [qw(tea.name), { count => 'tea.name' }],
      as           => [qw(name count)],
      result_class => 'DBIx::Class::ResultClass::HashRefInflator',
      order_by     => { -desc => \'count(tea.name)' }
   })
}

1;
