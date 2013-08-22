package TeaTime::Schema::ResultSet::Tea;

use parent 'TeaTime::Schema::ResultSet';
__PACKAGE__->load_components(qw(
   Helper::ResultSet::Random
   Helper::ResultSet::CorrelateRelationship
));

sub cli_find { $_[0]->search({ name => { -like => "%$_[1]%" } }) }

sub enabled { $_[0]->search({ enabled => 1}) }

sub order_by_last_drank {
   $_[0]->search(undef, {
      order_by => {
         -desc => $_[0]->correlate('tea_times')
            ->search(undef, { rows => 1 })
            ->in_order
            ->get_column('when_occured')
            ->as_query
      },
   });
}

1;
