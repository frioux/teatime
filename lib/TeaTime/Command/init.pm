package TeaTime::Command::init;

use 5.20.0;
use Moo;
use warnings NONFATAL => 'all';

extends 'TeaTime::Command';

sub abstract { 'initialize (and upgrade) database' }

sub usage_desc { 't init [version]' }

sub validate_args {
  my ($self, $opt, $args) = @_;

  $self->usage_error('init version must be an int') unless $args->[0] =~ /^\d+$/;
}

sub execute {
  my ($self, $opt, $args) = @_;

  my $schema = $self->app->schema;
  given ($args->[0]) {
    when (2) {
      $schema->deploy({ sources => ['Contact'] })
    }
    when (3) {
      $schema->deploy({ sources => [qw(Event EventType)] });
      my $rs = $self->app->tea_time_rs->search(undef, {
        '+select' => 'when_occured',
        '+as' => 'when',
      });
      for ($rs->all) {
        $_->add_to_events({
          type => { name => 'Chose Tea' },
          when_occurred => $_->get_column('when'),
        });
      }
    }
    when (4) {
      $schema->storage->dbh_do(sub {
        $_[1]->do('ALTER TABLE teas ADD COLUMN steep_time INT');
      });
    }
    when (5) {
      $schema->storage->dbh_do(sub {
        $_[1]->do('ALTER TABLE teas ADD COLUMN heaping INT');
      });
    }
    when (6) { $schema->deploy({ sources => [qw(Milk)] }) }
    default { $schema->deploy }
  }
}

1;
