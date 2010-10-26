package TeaTime::Schema::ResultSet::TeaTime;

use parent 'DBIx::Class::ResultSet';
__PACKAGE__->load_components('Helper::ResultSet::IgnoreWantarray');

sub in_order { $_[0]->search(undef, { order_by => { -desc => 'when_occured' } }) }

sub add_count {
   $_[0]->search(undef, {
      group_by     => 'tea.name',
      join      => 'tea',
      '+select' => [{ count => 'tea.name' }],
      '+as'     => [qw(count)],
   })
}

sub stats {
   $_[0]->add_count->search(undef, {
      '+select'    => [qw(tea.name)],
      '+as'        => [qw(name)],
      result_class => 'DBIx::Class::ResultClass::HashRefInflator',
      order_by     => { -desc => \'count(tea.name)' }
   })
}

1;
