package TeaTime::Schema::ResultSet::Tea;

use parent 'DBIx::Class::ResultSet';
__PACKAGE__->load_components('Helper::ResultSet::IgnoreWantarray');

sub cli_find { $_[0]->search({ name => { -like => "%$_[1]%" } }) }

sub enabled { $_[0]->search({ enabled => 1}) }

1;
