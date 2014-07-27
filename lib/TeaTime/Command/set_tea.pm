package TeaTime::Command::set_tea;

use 5.20.0;
use Moo;

extends 'TeaTime::Command';

sub abstract { 'set tea' }

sub usage_desc { 't set_tea <name>' }

sub execute {
  my ($self, $opt, $args) = @_;

  require DateTime;
  my $milk = (sub {
    my $days = int($self->app->schema->resultset('Milk')->in_order->first
      ->when_expires->subtract_datetime_absolute(DateTime->now)
      ->in_units('seconds')
    / 60 / 60 / 24) + 1; # as days
    if ($days == 0) {
      return ' [Milk expired today]'
    } elsif ($days == 1) {
      return ' [Milk expires tomorrow]'
    } elsif ($days == 2) {
      return ' [Milk expires in two days]'
    } elsif ($days < 0) {
      return ' [Milk expired ' . $days . ' day(s) ago]'
    }
    return '';
  })->();
  $self->app->single_item(sub {
    my $tt;
    my $tea = $_[0];
    $self->app->schema->txn_do(sub {
      $tt = $self->app->tea_time_rs->create({ tea_id => $tea->id });
      $tt->events->create({
        type => { name => 'Chose Tea' }
      });
    });
    say 'Setting tea to ' . $tea->name . ($tea->heaping ? ' (heaping)' : '');
    $self->app->send_message(
      sprintf 'Tea chosen: %s (%s) (%s)%s',
        $tea->name,
        $self->app->config->{servers}{api},
        $self->app->config->{servers}{human},
        $milk,
    );
  }, 'tea', $args->[0], $self->app->tea_rs->enabled);
}

1;
