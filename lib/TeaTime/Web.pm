package TeaTime::Web;
use Web::Simple;

use TeaTime::Util 'config';
use JSON ();
use TeaTime::Schema;
use List::Util::WeightedChoice 'choose_weighted';
use Time::Duration;
use TeaTime::Schema;

my $schema = TeaTime::Schema->connect({
   dsn      => config->{db},
   writable => config->{writable_db},
});

my $tea_rs = $schema->resultset('Tea');
my $tea_time_rs = $schema->resultset('TeaTime');
my $base_url = config->{web_server}{base_url};

sub rand { _success($tea_rs->enabled->rand->single->TO_JSON) }

sub most_rand {
   my @teas = $tea_time_rs->add_count->all;
   _success(choose_weighted(
      [map $_, @teas],
      [map $_->get_column('count'), @teas]
   )->tea->TO_JSON)
}

sub least_rand {
   my @teas = $tea_time_rs->add_count->all;
   _success(choose_weighted(
      [map $_, @teas],
      [map 1/$_->get_column('count'), @teas]
   )->tea->TO_JSON)
}

sub _success {
   my $s = $base_url;
    [
      200,
      [ 'Content-type', 'application/json; charset=utf-8' ],
      [
         JSON::encode_json( { data => $_[0] })
      ]
    ]
}

sub _fail {
   my $s = $base_url;
    [
      500,
      [ 'Content-type', 'application/json; charset=utf-8' ],
      [
         JSON::encode_json( { data => $_[0] })
      ]
    ]
}

sub main { _success([ map $_->TO_JSON, $tea_time_rs->in_order->all ]) }

sub last { _success([ map $_->TO_JSON, $tea_time_rs->in_order->slice(0, 10)->all ]) }

sub teas {
   my $t = time;
   _success([
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
   _success($tea_time_rs->in_order->search(undef, { rows => 1})->single->TO_JSON)
}

sub stats { _success([ $tea_time_rs->stats->all ]) }

use MIME::Base64;
use Crypt::Eksblowfish::Bcrypt 'bcrypt_hash';

sub verify_password {
   my %valid = %{shift @_};
   my %check = %{shift @_};

   my $salt = (split /;/, $valid{password})[1];

   my $encoded = encode_base64(bcrypt_hash({
      key_nul => 1,
      cost    => 8,
      salt    => $salt,
   }, $check{password}), '');

   return $check{user} eq $valid{user} && "$encoded;$salt" eq $valid{password}
}
sub dispatch_request {
   # need auth
   sub (?username=&password=) {
      my ($self, $username, $password) = @_;
      return unless verify_password({
         user     => config->{web_server}{username},
         password => config->{web_server}{password},
      }, {
         user     => $username,
         password => $password,
      });
      sub (POST) {
         sub (/contacts + ?jid=) {
            my ($self, $jid) = @_;
            $schema->resultset('Contact')->create({
               enabled => 1,
               jid => $jid
            });
            _success({})
         },
         sub (/teas + ?name=&steep_time=&is_heaping=) {
            my ($self, $name, $steep_time, $heaping) = @_;
            $schema->resultset('Tea')->create({
               name => $name,
               steep_time => $steep_time,
               heaping => $heaping,
               enabled => 1,
            });
            _success({})
         },
         sub (/events + ?name=) {
            my ($self, $name) = @_;
            $tea_time_rs->in_order->first->events->create({
               type => { name => $name }
            });
            _success({})
         },
         sub (/milk + ?expiration=) {
            my ($self, $expiration) = @_;
            $schema->resultset('Milk')->create({
               when_expires => "$expiration 00:00:00"
            });
            _success({})
         },
         sub (/current_tea + ?tea=) {
            my ($self, $tea_name) = @_;

            my $rs = $schema->resultset('Tea')->cli_find($tea_name);
            my $count = $rs->count;
            if ($count > 1) {
               return _fail({
                  err_code => 2,
                  message => 'More than one tea found',
                  teas    => [map $_->view, $rs->all],
               })
            } elsif ($count == 1) {
               my $tea = $rs->first;
               $schema->txn_do(sub {
                 my $tt = $tea_time_rs->create({ tea_id => $tea->id });
                 $tt->events->create({
                   type => { name => 'Chose Tea' }
                 });
               });
               return _success({
                  tea => $tea->TO_JSON,
                  milk => $schema->resultset('Milk')->in_order->get_column('when_expires')->first,
                  message => 'Setting tea to ' . $tea->name
                     . ($tea->heaping ? ' (heaping)' : ''),
                  });
            } else {
               return _fail({
                  err_code => 0,
                  message => "No tea '$tea_name' found",
               });
            }
         }
      },
      sub (/contacts)   { _success([ map $_->TO_JSON, $schema->resultset('Contact')->all ]) },
   },

   # no auth
   sub (/last_teas)   { $_[0]->last        },
   sub (/teas)        { $_[0]->teas        },
   sub (/stats)       { $_[0]->stats       },
   sub (/current_tea) { $_[0]->current_tea },
   sub (/rand)        { $_[0]->rand        },
   sub (/rand/most)   { $_[0]->most_rand   },
   sub (/rand/least)  { $_[0]->least_rand  },
}

TeaTime::Web->run_if_script;

