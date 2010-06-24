package TeaTime::Schema::Result::TeaTime;

use 5.12.1;

use parent 'TeaTime::Schema::Result';

use CLASS;

CLASS->load_components('TimeStamp');

CLASS->add_columns(
   id => {
      data_type         => 'integer',
      is_auto_increment => 1,
   },
   tea_id => {
      data_type => 'integer',
   },
   when_occured => {
      data_type     => 'timestamp',
      set_on_create => 1,
   },
);

CLASS->belongs_to( tea => 'TeaTime::Schema::Result::Tea' );

1;
