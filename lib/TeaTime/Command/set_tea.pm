package TeaTime::Command::set_tea;

use TeaTime -command;

use 5.12.1;
use Date::Calc qw(Date_to_Days Today);
use warnings;

sub abstract { 'set tea' }

sub usage_desc { 't set_tea <name>' }

sub milk_message {
   my ($self, @expiration) = @_;
   my $days = Date_to_Days(@expiration) - Date_to_Days(Today);
   if ($days == 0) {
     return ' [Milk expired today]'
   } elsif ($days == 1) {
     return ' [Milk expires tomorrow]'
   } elsif ($days == 2) {
     return ' [Milk expires in two days]'
   } elsif ($days < 0) {
     return ' [Milk expired ' . (-$days) . ' day(s) ago]'
   }
   return '';
}

sub execute {
  my ($self, $opt, $args) = @_;

  my $r = $self->app->api->add_tea_time($args->[0]);
  my $msg = $r->{data}{message};

  if ($r->{data}{success}) {
     my $tea = $r->{data}{tea};
     say 'Setting tea to ' . $tea->{name} . ($tea->{heaping} ? ' (heaping)' : '');
     $self->app->send_message(
      sprintf 'Tea chosen: %s (%s) (%s)%s',
         $tea->{name},
         $self->app->config->{servers}{api},
         $self->app->config->{servers}{human},
         $self->milk_message(split /-/, (split / /, $r->{data}{milk})[0]),
     );
  } else {
     given ($r->{data}{err_code}) {
        when (0) { say 'No tea of that name found' }
        when (2) {
           my $i = 0;
           say "$msg:";
           printf "%2d. %s\n", ++$i, $_ for @{$r->{data}{teas}};
        }
        default { say 'Unknown error' }
     }
  }
}

1;
