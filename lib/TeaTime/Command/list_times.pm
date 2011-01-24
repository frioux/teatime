package TeaTime::Command::list_times;

use TeaTime -command;

use 5.12.1;
use warnings;

sub abstract { 'print a list of tea times' }

sub execute {
  my ($self, $opt, $args) = @_;

  my $x = 0;
  say sprintf '%s: %s', $_->{events}[0]{when}, $_->{name} for
    sort { $a->{events}[0]{when} cmp $b->{events}[0]{when} }
    @{$self->app->api->get_tea_times->{json}{data}},
}

1;
