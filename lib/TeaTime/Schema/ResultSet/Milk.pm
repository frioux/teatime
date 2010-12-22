package TeaTime::Schema::ResultSet::Milk;

use parent 'TeaTime::Schema::ResultSet';

sub in_order {
   shift->search(undef, { order_by => { -desc => 'when_expires'} })
}

1;

