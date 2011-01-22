package TeaTime::Schema::Result::Contact;

use DBIx::Class::Candy -base => 'TeaTime::Schema::Result', -perl5 => v12,
   -components => [ 'Helper::Row::ToJSON' ];

table 'contacts';

column id => {
   data_type         => 'integer',
   is_auto_increment => 1,
};

column jid => {
   data_type => 'varchar',
   size      => 50,
};

column enabled => {
   data_type => 'integer',
   size      => 1,
};

primary_key 'id';

unique_constraint [qw( jid )];

sub toggle { $_[0]->enabled($_[0]->enabled?0:1); $_[0] }

sub view { $_[0]->jid }

1;
