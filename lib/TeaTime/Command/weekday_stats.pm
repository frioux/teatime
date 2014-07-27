package TeaTime::Command::weekday_stats;

use 5.20.0;
use Moo;
use experimental 'signatures';

extends 'TeaTime::Command';

sub abstract { 'get stats based on weekday' }

sub usage_desc { 't weekday_stats' }

sub execute ($self, $opt, $args) {
  my %teas;
  $teas{$_->{tea}}[$_->{weekday}] = $_->{count} for $self->app->tea_time_rs->search(undef, {
    result_class => 'DBIx::Class::ResultClass::HashRefInflator',
    join     => 'tea',
    select   => [qw(tea.name), { count => '*'}, \'strftime("%w",me.when_occured) - 1'],
    as       => [qw(tea), 'count', 'weekday'],
    group_by => ['tea.name','strftime("%w",me.when_occured) - 1'],
  })->all;

  require Text::SimpleTable;

  my $t = Text::SimpleTable->new(
    [30, 'tea'],
    map [3, $_], qw( Mon Tue Wed Thu Fri )
  );

  $t->row($_, @{$teas{$_}}) for keys %teas;

  print $t->draw;
}

1;
