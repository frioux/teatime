package TeaTime::Schema::ResultSet::Contact;

use 5.20.0;
use warnings;

use experimental 'signatures';

use parent 'TeaTime::Schema::ResultSet';

__PACKAGE__->load_components('Helper::ResultSet::Random');

sub cli_find { $_[0]->search({ jid => { -like => "%$_[1]%" } }) }

sub find_by_jid ($s, $j) { $s->search({ jid => $j })->single }

sub enabled { $_[0]->search({ enabled => 1}) }

1;

