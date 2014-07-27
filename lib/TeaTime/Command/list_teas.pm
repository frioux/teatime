package TeaTime::Command::list_teas;

use 5.20.0;
use Moo;
use experimental 'signatures';

extends 'TeaTime::Command';

sub abstract { 'print a list of teas' }

sub opt_spec {
  return (
    [ "on-hand|O",  "only show teas on hand" ],
    [ "order-by-drank|D",  "order_by last drank" ],
  );
}

sub execute ($self, $opt, $args) {
  my $x = 0;
  my $rs = $self->app->tea_rs;
  if ($opt->order_by_drank) {
    $rs = $rs->order_by_last_drank
  } else {
    $rs = $rs->search(undef, {
       order_by => [{ -desc => 'enabled' }, 'name' ]
     })
  }
  $rs = $rs->enabled if $opt->{on_hand};
  print join '', map sprintf("%2d. %s %s\n", ++$x, ($_->enabled?'*':' '), $_->name),
    $rs->all
}

1;
