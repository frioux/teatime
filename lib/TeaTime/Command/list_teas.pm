package TeaTime::Command::list_teas;

use TeaTime -command;

use 5.12.1;
use warnings;

sub abstract { 'print a list of teas' }

sub execute {
  my ($self, $opt, $args) = @_;

  my $x = 0;
  print join '', map sprintf("%2d. %s %s\n", ++$x, ($_->enabled?'*':' '), $_->name),
    $self->app->tea_rs->search(undef, {
      order_by => [{ -desc => 'enabled' }, 'name' ]
    })->all
}

1;
