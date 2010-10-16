package TeaTime::Schema::Result::TeaTime;

use DBIx::Class::Candy
   -base => 'TeaTime::Schema::Result',
   -components => ['TimeStamp'],
   -perl5 => v12;

table 'tea_times';

column id => {
   data_type         => 'integer',
   is_auto_increment => 1,
};

column tea_id => {
   data_type => 'integer',
};

column when_occured => {
   data_type     => 'timestamp',
   set_on_create => 1,
};

primary_key 'id';
belongs_to tea => 'TeaTime::Schema::Result::Tea', 'tea_id';

1;
