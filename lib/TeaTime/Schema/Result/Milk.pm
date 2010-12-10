package TeaTime::Schema::Result::Milk;

use DBIx::Class::Candy
   -base       => 'TeaTime::Schema::Result',
   -perl5      => v12,
   -components => ['InflateColumn::DateTime'];

table 'milk';

column id => {
   data_type         => 'integer',
   is_auto_increment => 1,
};

column when_expires => { data_type => 'datetime' };

primary_key 'id';

1;

