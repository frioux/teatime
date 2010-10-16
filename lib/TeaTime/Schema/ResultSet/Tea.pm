package TeaTime::Schema::ResultSet::Tea;

use parent 'DBIx::Class::ResultSet';

sub cli_find { $_[0]->search({ name => { -like => "%$_[1]%" } }) }

1;
