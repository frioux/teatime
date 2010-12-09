package TeaTime::Command::list_times;

use TeaTime -command;

use 5.12.1;
use warnings;

sub abstract { 'print a list of tea times' }

sub execute {
  my ($self, $opt, $args) = @_;

  my $x = 0;
  say sprintf '%s: %s', $_->when_occured->ymd, $_->tea->name
     for $self->app->tea_time_rs->search(undef, {
        prefetch => 'tea',
        order_by => 'when_occured'
     })->all
}

1;
