package TeaTime::Schema::Result::TeaTime;

use DBIx::Class::Candy
   -base => 'TeaTime::Schema::Result',
   -components => ['TimeStamp'],
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
   my $ret = {
      name => $self->tea->name,
      events => [map +{
         name => $_->type->name,
         when => $_->get_column('when_occurred'),
         human => duration($t - $_->when_occurred->epoch),
      }, $self->events
         ->search(undef, { order_by => { -desc => 'when_occurred' } })
         ->all],
   };

   my $events = $self->events->search(undef, { join => 'type' });

   my $chose = $events->search({ 'type.name' => 'Chose Tea'     })->next;
   my $ready = $events->search({ 'type.name' => 'Ready'         })->next;
   my $start = $events->search({ 'type.name' => 'Started Steep' })->next;
   my $stop  = $events->search({ 'type.name' => 'Stopped Steep' })->next;
   my $empty = $events->search({ 'type.name' => 'Pot Empty'     })->next;

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
