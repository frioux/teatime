package TeaTime::Schema::Result;

use 5.12.1;
use warnings;

use parent 'DBIx::Class::Core';

sub insert {
  my $self = shift;
  return $self->next::method(@_)
     if $self->result_source->storage->_dbic_connect_attributes->{writable}
}

sub update {
  my $self = shift;
  return $self->next::method(@_)
     if $self->result_source->storage->_dbic_connect_attributes->{writable}
}

sub delete {
  my $self = shift;
  return $self->next::method(@_)
     if $self->result_source->storage->_dbic_connect_attributes->{writable}
}

1;

