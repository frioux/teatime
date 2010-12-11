package TeaTime::Command::init;

use TeaTime -command;

use 5.12.1;
use warnings;

sub abstract { 'initialize (and upgrade) database' }

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
    default { $schema->deploy }
  }
}

1;