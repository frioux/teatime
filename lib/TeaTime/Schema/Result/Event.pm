package TeaTime::Schema::Result::Event;

use DBIx::Class::Candy
   -base       => 'TeaTime::Schema::Result',
   -perl5      => v12,
   -components => ['TimeStamp'];

table 'events';

column id => {
   data_type         => 'integer',
   is_auto_increment => 1,
};

column tea_time_id => { data_type => 'integer' };

column type_id => { data_type => 'integer' };

column when_occurred => {
   data_type     => 'datetime',
   set_on_create => 1,
};

primary_key 'id';

unique_constraint [qw( tea_time_id type_id )];

belongs_to tea_time => 'TeaTime::Schema::Result::TeaTime', 'tea_time_id';
belongs_to type => 'TeaTime::Schema::Result::EventType', 'type_id';

1;

