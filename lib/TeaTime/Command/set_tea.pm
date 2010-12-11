package TeaTime::Command::set_tea;

use TeaTime -command;

use 5.12.1;
use warnings;

sub abstract { 'set tea' }

sub usage_desc { 't set_tea <name>' }

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
      $self->app->send_message(
        sprintf 'Tea chosen: %s (%s) (%s)',
          $tea->name,
          $self->app->config->{servers}{api},
          $self->app->config->{servers}{human}
      );
   }, 'tea', $args->[0], $self->app->tea_rs->enabled);
}

1;
