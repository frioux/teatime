#!/usr/bin/env perl

use 5.20.0;
use warnings;

use Test::More;
use App::Cmd::Tester;

use lib 't/lib';

use A;

my $app = app();

stdout_is(
   test_app($app => [qw(new_milk 2019-12-12)]),
   [ 'creating milk expiration date for 2019-12-12'],
   'created milk',
);

stdout_is(
   test_app($app => [qw(create_tea), 'Golden Monkey', 180, 0]),
   [ 'created Golden Monkey'],
   'probably created tea',
);

stdout_is(
   test_app($app => [qw(set_tea Golden)]),
   [ 'Setting tea to Golden Monkey'],
   'set_tea',
);

done_testing;
