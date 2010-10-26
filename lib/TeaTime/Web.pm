use Web::Simple 'TeaTime::Web';
{
   package TeaTime::Web;

   use JSON ();
   use TeaTime::Schema;
   use List::Util::WeightedChoice 'choose_weighted';
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
                  $s/most_rand $s/least_rand $s/rand
               )],
            })
         ]
       ]
   }

   sub main { _fromat([ map $_->TO_JSON, $tea_time_rs->in_order->all ]) }

   sub teas {
      _fromat([
         map $_->TO_JSON, $tea_rs->search(undef, { order_by => 'name' })->all
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
            sub (/most_rand)   { $self->most_rand   },
            sub (/least_rand)  { $self->least_rand  },
         ] }
      }
   };
}

TeaTime::Web->run_if_script;

