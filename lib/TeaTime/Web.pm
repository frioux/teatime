use Web::Simple 'TeaTime::Web';
{
   package TeaTime::Web;

   use JSON ();
   use TeaTime::Schema;
   use List::Util::WeightedChoice 'choose_weighted';
   use Time::Duration;
   my $schema = TeaTime::Schema->connect('dbi:SQLite:dbname=.teadb');
   my $tea_rs = $schema->resultset('Tea');
   my $tea_time_rs = $schema->resultset('TeaTime');
   my $host;

   sub rand {
      _fromat($tea_rs->enabled->rand->single->TO_JSON)
   }

   sub most_rand {
      my @teas = $tea_time_rs->add_count->all;
      _fromat(choose_weighted(
         [map $_, @teas],
         [map $_->get_column('count'), @teas]
      )->tea->TO_JSON)
   }

   sub least_rand {
      my @teas = $tea_time_rs->add_count->all;
      _fromat(choose_weighted(
         [map $_, @teas],
         [map 1/$_->get_column('count'), @teas]
      )->tea->TO_JSON)
   }

   sub _fromat {
      my $s = 'http://' . $host;
       [
         200,
         [ 'Content-type', 'application/json' ],
         [
            JSON::encode_json( {
               data => $_[0],
               see_also => [split /\s+/, qq($s/stats $s/current_tea $s/last_teas $s/teas
                  $s/rand/most $s/rand/least $s/rand
               )],
            })
         ]
       ]
   }

   sub main { _fromat([ map $_->TO_JSON, $tea_time_rs->in_order->all ]) }

   sub teas {
      my $t = time;
      _fromat([
         map +{
            %{ $_->TO_JSON },
            last_drank => duration($t - $_->get_column('last_drank')),
         }, $tea_rs->search(undef, {
            order_by  => 'name',
            group_by  => 'me.id',
            join      => { tea_times => 'events' },
            '+select' => \'MAX(strftime("%s", events.when_occurred))',
            '+as'     => 'last_drank',
         })->all
      ])
   }

   sub current_tea {
      _fromat($tea_time_rs->in_order->search(undef, { rows => 1})->single->TO_JSON)
   }

   sub stats { _fromat([ $tea_time_rs->stats->all ]) }

   dispatch {
      sub () {
         $host = $_[PSGI_ENV]->{HTTP_HOST};
         subdispatch sub { [
            sub (/)            { $self->main        },
            sub (/last_teas)   { $self->main        },
            sub (/teas)        { $self->teas        },
            sub (/stats)       { $self->stats       },
            sub (/current_tea) { $self->current_tea },
            sub (/rand)        { $self->rand        },
            sub (/rand/most)   { $self->most_rand   },
            sub (/rand/least)  { $self->least_rand  },
         ] }
      }
   };
}

TeaTime::Web->run_if_script;

