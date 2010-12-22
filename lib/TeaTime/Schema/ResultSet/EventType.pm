package TeaTime::Schema::ResultSet::EventType;

use parent 'TeaTime::Schema::ResultSet';

sub cli_find { $_[0]->search({ name => { -like => "%$_[1]%" } }) }

1;

