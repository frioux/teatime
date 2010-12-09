package TeaTime::Command::set_tea;

use TeaTime -command;

use 5.12.1;
use warnings;

sub execute {
  my ($self, $opt, $args) = @_;

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
      $self->app->send_message('Tea chosen: ' . $tt->tea->name .
         ' (http://valium.lan.mitsi.com:8320) (http://akama.lan.mitsi.com:5000)');
   }, 'tea', $args->[0], $self->app->tea_rs->enabled);
}

1;
