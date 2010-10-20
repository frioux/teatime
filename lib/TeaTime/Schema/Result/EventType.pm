package TeaTime::Schema::Result::EventType;

use DBIx::Class::Candy
   -base       => 'TeaTime::Schema::Result',
   -perl5      => v12,
   -components => ['TimeStamp'];

table 'event_types';

column id => {
   data_type         => 'integer',
   is_auto_increment => 1,
};

column name => {
   data_type => 'varchar',
   size => 20,
};

primary_key 'id';

unique_constraint ['name'];

has_many events => 'TeaTime::Schema::Result::Event', 'type_id';

1;


