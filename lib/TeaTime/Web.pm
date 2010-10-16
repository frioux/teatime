use Web::Simple 'TeaTime::Web';
{
   package TeaTime::Web;

   use JSON ();
   use TeaTime::Schema;
   use Time::Duration;
   my $schema = TeaTime::Schema->connect('dbi:SQLite:dbname=.teadb');
   my $tea_rs = $schema->resultset('Tea');
   my $tea_time_rs = $schema->resultset('TeaTime');

   sub _fromat {
      my $s = 'http://valium.lan.mitsi.com:8320';
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

   sub main {
      my $t = time;
      _fromat([ map +{
            name => $_->tea->name,
            when => $_->when_occured->ymd,
            human => duration($t - $_->when_occured->epoch),
      }, $tea_time_rs->in_order->all ])
   }

   sub teas {
      _fromat([
         map +{
            name => $_->name,
         }, $tea_rs->search(undef, { order_by => 'name' })->all
      ])
   }

   sub current_tea {
      _fromat([
         $tea_time_rs->in_order->format->search(undef, { rows => 1})->single
      ])
   }

   sub stats {
      _fromat([ $tea_time_rs->stats->all ])
   }

   dispatch {
      sub (/)            { $self->main        },
      sub (/last_teas)   { $self->main        },
      sub (/teas)        { $self->teas        },
      sub (/stats)       { $self->stats       },
      sub (/current_tea) { $self->current_tea },
   };
}

TeaTime::Web->run_if_script;

