package TeaTime::Schema::ResultSet::EventType;

use parent 'DBIx::Class::ResultSet';

__PACKAGE__->load_components(qw(
   Helper::ResultSet::IgnoreWantarray
));

sub cli_find { $_[0]->search({ name => { -like => "%$_[1]%" } }) }

1;

