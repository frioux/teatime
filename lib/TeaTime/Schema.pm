package TeaTime::Schema;

use 5.12.1;

use parent 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces(
   default_resultset_class => '+TeaTime::Schema::ResultSet',
);

1;
