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

stdout_is(
   test_app($app => [qw(list_contacts)]),
   [ '1. foo@bar.com'],
   'list_contacts',
);

stdout_is(
   test_app($app => [qw(toggle_contact foo)]),
   [ 'Toggling foo@bar.com to disabled'],
   'toggle_contact',
);

stdout_is(
   test_app($app => [qw(toggle_contact foo)]),
   [ 'Toggling foo@bar.com to enabled'],
   'toggle_contact',
);

done_testing;
