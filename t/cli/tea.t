#!/usr/bin/env perl

use 5.20.0;
use warnings;

use Test::More;
use App::Cmd::Tester;

use lib 't/lib';

use A;

my $app = app();

stdout_is(
   test_app($app => [qw(create_tea), 'Golden Monkey', 180, 0]),
   [ 'created Golden Monkey'],
   'probably created tea',
);

ok(
   $app->tea_rs->find_by_name('Golden Monkey'),
   'definitely created tea',
);

stdout_is(
   test_app($app => [qw(list_teas)]),
   [ ' 1. * Golden Monkey'],
   'list_teas',
);

stdout_is(
   test_app($app => [qw(toggle_tea golden)]),
   [ 'Toggling Golden Monkey to disabled'],
   'toggle_tea',
);

stdout_is(
   test_app($app => [qw(toggle_tea golden)]),
   [ 'Toggling Golden Monkey to enabled'],
   'toggle_tea',
);

done_testing;
