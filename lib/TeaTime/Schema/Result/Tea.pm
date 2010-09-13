package TeaTime::Schema::Result::Tea;

use 5.12.1;
use warnings;

use parent 'TeaTime::Schema::Result';

use CLASS;
CLASS->table('teas');
CLASS->load_components(qw(KiokuDB));

CLASS->add_columns(
   id => {
      data_type         => 'integer',
      is_auto_increment => 1,
   },
   name => {
      data_type => 'varchar',
      size      => 50,
   },
   enabled => {
      data_type => 'integer',
      size      => 1,
   },
   metadata => {
      data_type => 'varchar',
      is_nullable => 1,
   },
);

CLASS->kiokudb_column('metadata');

CLASS->set_primary_key('id');
CLASS->has_many( tea_times => 'TeaTime::Schema::Result::TeaTime', 'tea_id' );
CLASS->add_unique_constraint([qw( name )]);
sub toggle { $_[0]->enabled($_[0]->enabled?0:1); $_[0] }

1;
