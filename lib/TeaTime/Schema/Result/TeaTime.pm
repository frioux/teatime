package TeaTime::Schema::Result::TeaTime;

use DBIx::Class::Candy
   -base => 'TeaTime::Schema::Result',
   -components => ['TimeStamp'],
   -perl5 => v12;

use Time::Duration;
use List::Util 'first';

table 'tea_times';

column id => {
   data_type         => 'integer',
   is_auto_increment => 1,
};

column tea_id => {
   data_type => 'integer',
};

column when_occured => {
   data_type => 'timestamp',
   set_on_create => 1,
};

primary_key 'id';
belongs_to tea => 'TeaTime::Schema::Result::Tea', 'tea_id';
has_many events => 'TeaTime::Schema::Result::Event', 'tea_time_id';

sub TO_JSON {
   my $self = shift;
   my $t = time;

   my @events = $self->events->search(undef, {
      prefetch => 'type',
      order_by => { -desc => 'when_occurred' },
   })->all;

   my $ret = {
      name => $self->tea->name,
      prescribed_steep_time => $self->tea->steep_time,
      events => [map +{
         name => $_->type->name,
         when => $_->get_column('when_occurred'),
         human => duration($t - $_->when_occurred->epoch),
      }, @events],
   };


   my $chose = first { $_->type->name eq 'Chose Tea'     } @events;
   my $ready = first { $_->type->name eq 'Ready'         } @events;
   my $start = first { $_->type->name eq 'Started Steep' } @events;
   my $stop  = first { $_->type->name eq 'Stopped Steep' } @events;
   my $empty = first { $_->type->name eq 'Pot Empty'     } @events;

   $ret->{preparation_time} = (($chose && $ready)
      ? duration($ready->when_occurred->epoch - $chose->when_occurred->epoch)
      : undef);

   $ret->{steep_time} = (($start && $stop)
      ? duration($stop->when_occurred->epoch - $start->when_occurred->epoch)
      : undef);

   $ret->{available_time} = (($ready && $empty)
      ? duration($ready->when_occurred->epoch - $empty->when_occurred->epoch)
      : undef);

   return $ret;
}

1;
