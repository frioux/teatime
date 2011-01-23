package TeaTime::Util;

use 5.12.1;
use warnings;

use FindBin '$Bin';
use JSON;
use List::Util 'first';
use File::HomeDir;

use Sub::Exporter -setup => {
  exports => [ qw(config) ],
  collectors => [ 'defaults' ],
};
sub config {
   state $config = decode_json(do {
     my $f = '.teatime.json';
     local( @ARGV, $/ ) =  first { -f $_ } "$Bin/$f", home()."/$f", $f; <>
   });

   $config->{send_messages} //= exists $ENV{TXMPP} ? $ENV{TXMPP} : 1;

   $config->{writable_db}   //= exists $ENV{TDB}   ? $ENV{TDB}   : 1;

   $config
}


1;
