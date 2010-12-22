package TeaTime::Schema::ResultSet::Contact;

use parent 'TeaTime::Schema::ResultSet';

__PACKAGE__->load_components('Helper::ResultSet::Random');

sub cli_find { $_[0]->search({ jid => { -like => "%$_[1]%" } }) }

sub enabled { $_[0]->search({ enabled => 1}) }

1;

