package TeaTime::Schema::ResultSet;

use 5.12.1;
use warnings;

use parent 'DBIx::Class::ResultSet';

__PACKAGE__->load_components(qw(
   Helper::ResultSet::IgnoreWantarray
));

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
