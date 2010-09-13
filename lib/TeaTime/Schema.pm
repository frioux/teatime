package TeaTime::Schema;

use 5.12.1;

use parent 'DBIx::Class::Schema';

__PACKAGE__->load_components(qw(Schema::KiokuDB));
__PACKAGE__->load_namespaces;

1;
