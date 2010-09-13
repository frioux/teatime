use Web::Simple 'TeaTime::Web';
{
   package TeaTime::Web;

   use JSON ();
   use TeaTime::Schema;
   my $schema = TeaTime::Schema->connect('dbi:SQLite:dbname=.teadb');
   my $tea_rs = $schema->resultset('Tea');
   my $tea_time_rs = $schema->resultset('TeaTime');

   sub _fromat {
       [
         200,
         [ 'Content-type', 'application/json' ],
         [
            JSON::encode_json( {
               data => $_[0],
               see_also => [qw(/stats /current_tea /last_teas /teas)],
            })
         ]
       ]
   }

   sub main {
      _fromat([ $tea_time_rs->in_order->format->all ])
   }

   sub teas {
      _fromat([
         map +{
            name => $_->name,
            #($_->metadata?(
               #time => $_->metadata->time,
               #heaping => $_->metadata->is_heaping,
            #):())
         }, $tea_rs->search(undef, { order_by => 'name' })->all
      ])
   }

   sub current_tea {
      _fromat([
         $tea_time_rs->in_order->format->search(undef, { rows => 1})->single
      ])
   }

   sub stats {
      _fromat([ $tea_time_rs->in_order->stats->all ])
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

