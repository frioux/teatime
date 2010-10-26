package TeaTime::Schema::Result::Tea;

use DBIx::Class::Candy -base => 'TeaTime::Schema::Result', -perl5 => v12;

table 'teas';

column id => {
   data_type         => 'integer',
   is_auto_increment => 1,
};

column name => {
   data_type => 'varchar',
   size      => 50,
};

column steep_time => { data_type => 'int' };

column enabled => {
   data_type => 'integer',
   size      => 1,
};

primary_key 'id';
has_many tea_times => 'TeaTime::Schema::Result::TeaTime', 'tea_id';
unique_constraint [qw( name )];

sub toggle { $_[0]->enabled($_[0]->enabled?0:1); $_[0] }

sub view { $_[0]->name }

1;
