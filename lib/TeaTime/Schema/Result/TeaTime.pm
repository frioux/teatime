package TeaTime::Schema::Result::TeaTime;

use DBIx::Class::Candy
   -base => 'TeaTime::Schema::Result',
   -perl5 => v12;
use Time::Duration;

table 'tea_times';

column id => {
   data_type         => 'integer',
   is_auto_increment => 1,
};

column tea_id => {
   data_type => 'integer',
};

primary_key 'id';
belongs_to tea => 'TeaTime::Schema::Result::Tea', 'tea_id';
has_many events => 'TeaTime::Schema::Result::Event', 'tea_time_id';

sub TO_JSON {
   my $self = shift;
   my $t = time;
   return +{
      name => $self->tea->name,
      events => [map +{
         name => $_->type->name,
         when => $_->get_column('when_occurred'),
         human => duration($t - $_->when_occurred->epoch),
      }, $self->events->all],
   }
}

1;
