package TeaTime::Command::undo;

use 5.20.0;
use Moo;

extends 'TeaTime::Command';

sub abstract { 'undo the last set_tea' }

sub usage_desc { 't undo [--force]' }

sub execute {
  my ($self, $opt, $args) = @_;

  my $t = $self->app->tea_time_rs->search(undef, {
    order_by => { -desc => 'when_occured' }
  })->first;
  if ($args->[0]) {
    say 'undoing last tea time: ' . $t->when_occured->ymd . ', ' . $t->tea->name;
    $t->delete;
  } else {
    say 'would undo last tea time: ' . $t->when_occured->ymd . ', ' . $t->tea->name;
  }
}

1;
