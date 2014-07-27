package TeaTime::Command::list_times;

use 5.20.0;
use Moo;
use experimental 'signatures';

extends 'TeaTime::Command';

sub abstract { 'print a list of tea times' }

sub execute ($self, $opt, $args) {
  my $x = 0;
  say sprintf '%s: %s', $_->when_occured->ymd, $_->tea->name
     for $self->app->tea_time_rs->search(undef, {
        prefetch => 'tea',
        order_by => 'when_occured'
     })->all
}

1;
