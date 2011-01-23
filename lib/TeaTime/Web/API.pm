package TeaTime::Web::API;

use Moo;
use HTTP::Tiny;
use URI;
use Sub::Quote;
use JSON;

has http_tiny => (
   is => 'ro',
   default => quote_sub q{ HTTP::Tiny->new( timeout => 1 ) },
);

has api_root => (
   is => 'ro',
   default => quote_sub q{ 'http://localhost:5000' },
);

has username => (
   is => 'ro',
   required => 1,
);

has password => (
   is => 'ro',
   required => 1,
);

sub _dejson { decode_json($_[0]->{content})->{data} }

sub _build_url {
   my ($self, $url, $params) = @_;

   my $uri = URI->new($self->api_root . $url);

   $uri->query_form($params);

   "$uri"
}

sub _post   {
   my ($self, $url, $params) = @_;

   $params = {
      %$params,
      username => $self->username,
      password => $self->password,
   };
   $self->http_tiny->request( POST   => $self->_build_url($url, $params) )
}
sub _get    { $_[0]->http_tiny->request( GET    => $_[0]->_build_url($_[1], $_[2]) ) }
sub _put    { $_[0]->http_tiny->request( PUT    => $_[0]->_build_url($_[1], $_[2]) ) }
sub _delete { $_[0]->http_tiny->request( DELETE => $_[0]->_build_url($_[1], $_[2]) ) }

sub add_contact { $_[0]->_post('/contacts', { jid => $_[1] }) }
sub get_contacts {
   my $self = shift;
   _dejson(
      $self->_get('/contacts', {
         username => $self->username,
         password => $self->password,
      })
   )
}

sub add_event { $_[0]->_post('/events', { name => $_[1] }) }

sub add_milk { $_[0]->_post('/milk', { expiration => $_[1] }) }
sub get_milk { $_[0]->_get('/milk') }

sub add_tea {
   $_[0]->_post('/teas', {
      name => $_[1],
      steep_time => $_[2],
      is_heaping => $_[3]
   })
}
sub get_tea { _dejson($_[0]->_get('/teas')) }

sub add_tea_time {
   decode_json($_[0]->_post('/current_tea', { tea => $_[1] })->{content})
}
sub get_tea_times { _dejson($_[0]->_get('/last_teas')) }
sub get_current_tea_time { _dejson($_[0]->_get('/current_tea')) }

1;
