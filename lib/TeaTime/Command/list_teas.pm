package TeaTime::Command::list_teas;

use TeaTime -command;

use 5.12.1;
use warnings;

sub abstract { 'print a list of teas' }

sub opt_spec {
  return (
    [ "on-hand|O",  "only show teas on hand" ],
  );
}

sub execute {
  my ($self, $opt, $args) = @_;

  my $x = 0;
  my $rs = $self->app->tea_rs->search(undef, {
    order_by => [{ -desc => 'enabled' }, 'name' ]
  });
  $rs = $rs->enabled if $opt->{on_hand};
  print join '', map sprintf("%2d. %s %s\n", ++$x, ($_->enabled?'*':' '), $_->name),
    $rs->all
}

1;
