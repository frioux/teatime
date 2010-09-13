package TeaTime::Model::Instructions;

use Moose;

has time => (
   isa => 'Str',
   is  => 'rw',
);

has is_heaping => (
   isa => 'Bool',
   is  => 'rw',
);

1;
