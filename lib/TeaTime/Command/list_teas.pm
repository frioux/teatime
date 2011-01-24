package TeaTime::Command::list_teas;

use TeaTime -command;

use 5.12.1;
use warnings;

sub abstract { 'print a list of teas' }

sub execute {
  my ($self, $opt, $args) = @_;

  my $x = 0;
  print join '', map sprintf("%2d. %s %s\n", ++$x, ($_->{enabled}?'*':' '), $_->{name}),
    sort { $b->{enabled} cmp $a->{enabled} or $a->{name} cmp $b->{name} }
    @{$self->app->api->get_tea->{json}{data}},
}

1;
