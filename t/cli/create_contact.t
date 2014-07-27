#!/usr/bin/env perl

use 5.20.0;
use warnings;

use Test::More;
use App::Cmd::Tester;

use lib 't/lib';

use A;

my $app = app();

stdout_is(
   test_app($app => [qw(create_contact foo@bar.com)]),
   [ 'created foo@bar.com'],
   'probably created contact',
);

ok(
   $app->contact_rs->find_by_jid('foo@bar.com'),
   'definitely created contact',
);

done_testing;
