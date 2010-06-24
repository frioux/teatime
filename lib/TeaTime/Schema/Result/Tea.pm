package TeaTime::Schema::Result::Tea;

use 5.12.1;

use parent 'TeaTime::Schema::Result';

use CLASS;

CLASS->add_columns(
   id => {
      data_type         => 'integer',
      is_auto_increment => 1,
   },
   name => {
      data_type => 'varchar',
      size      => 50,
   },
);

CLASS->has_many( tea_times => 'TeaTime::Schema::Result::TeaTime' );

1;
