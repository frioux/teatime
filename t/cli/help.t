#!/usr/bin/env perl

use 5.20.0;
use warnings;

use Test::More;
use App::Cmd::Tester;

use lib 't/lib';

use A;

my $app = app();

stdout_is(
   test_app($app => ['help']),
   [
      split /\n/, <<'HELP'
Available commands:

        commands: list the application's commands
            help: display a command's help screen

  create_contact: create a new contact
      create_tea: create a new tea
           empty: mark pot as empty
           event: mark pot with arbitrary event
            init: initialize (and upgrade) database
   list_contacts: print a list of contacts
       list_teas: print a list of teas
      list_times: print a list of tea times
         message: send message
        new_milk: add new milk for expiration date tracking
          server: run tea server
         set_tea: set tea
           timer: run timer for last set tea
  toggle_contact: toggle contact
      toggle_tea: toggle tea
            undo: undo the last set_tea
   weekday_stats: get stats based on weekday
HELP
   ],
   'help!',
);

done_testing;
