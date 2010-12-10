package TeaTime::Schema::ResultSet::Milk;

use parent 'DBIx::Class::ResultSet';

__PACKAGE__->load_components(qw(
   Helper::ResultSet::IgnoreWantarray
));

sub in_order {
   shift->search(undef, { order_by => { -desc => 'when_expires'} })
}

1;

