package TeaTime::Web;
use Web::Simple;

use TeaTime;
use JSON ();
use TeaTime::Schema;
use List::Util::WeightedChoice 'choose_weighted';
use Time::Duration;
my $schema = TeaTime->schema;
my $tea_rs = $schema->resultset('Tea');
my $tea_time_rs = $schema->resultset('TeaTime');
my $base_url = TeaTime->config->{web_server}{base_url};

sub rand { _fromat($tea_rs->enabled->rand->single->TO_JSON) }

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
   my $s = $base_url;
    [
      200,
      [ 'Content-type', 'application/json; charset=utf-8' ],
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

sub last { _fromat([ map $_->TO_JSON, $tea_time_rs->in_order->slice(0, 10)->all ]) }

sub teas {
   my $t = time;
   _fromat([
      map +{
         %{ $_->TO_JSON },
         last_drank => ($_->get_column('last_drank')?duration($t - $_->get_column('last_drank')):undef),
      }, $tea_rs->search(undef, {
         order_by  => 'name',
         group_by  => 'me.id',
         join      => { tea_times => 'events' },
         '+select' => {
            max => {
               strftime => [ '"%s"', 'events.when_occurred' ]
            }
         },
         '+as'     => 'last_drank',
      })->all
   ])
}

sub current_tea {
   _fromat($tea_time_rs->in_order->search(undef, { rows => 1})->single->TO_JSON)
}

sub stats { _fromat([ $tea_time_rs->stats->all ]) }

sub dispatch_request {
   sub (/)            { $_[0]->main        },
   sub (/last_teas)   { $_[0]->last        },
   sub (/teas)        { $_[0]->teas        },
   sub (/stats)       { $_[0]->stats       },
   sub (/current_tea) { $_[0]->current_tea },
   sub (/rand)        { $_[0]->rand        },
   sub (/rand/most)   { $_[0]->most_rand   },
   sub (/rand/least)  { $_[0]->least_rand  },
}

TeaTime::Web->run_if_script;

