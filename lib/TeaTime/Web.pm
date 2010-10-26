use Web::Simple 'TeaTime::Web';
{
   package TeaTime::Web;

   use JSON ();
   use TeaTime::Schema;
   my $schema = TeaTime::Schema->connect('dbi:SQLite:dbname=.teadb');
   my $tea_rs = $schema->resultset('Tea');
   my $tea_time_rs = $schema->resultset('TeaTime');
   my $host;

   sub _fromat {
      my $s = 'http://' . $host;
       [
         200,
         [ 'Content-type', 'application/json' ],
         [
            JSON::encode_json( {
               data => $_[0],
               see_also => [split / /, qq($s/stats $s/current_tea $s/last_teas $s/teas)],
            })
         ]
       ]
   }

   sub main { _fromat([ map $_->TO_JSON, $tea_time_rs->in_order->all ]) }

   sub teas {
      _fromat([
         map +{
            name => $_->name,
            ( defined $_->steep_time ? ( steep_time => $_->steep_time . ' seconds' ) : () ),
            heaping => ($_->heaping ? \1 : \0 ),
         }, $tea_rs->search(undef, { order_by => 'name' })->all
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
         ] }
      }
   };
}

TeaTime::Web->run_if_script;

