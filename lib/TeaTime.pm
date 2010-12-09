package TeaTime;

use App::Cmd::Setup -app;

use TeaTime::Schema;
use FindBin;

my $schema = TeaTime::Schema->connect("dbi:SQLite:dbname=$FindBin::Bin/../.teadb");
my $tea_rs = $schema->resultset('Tea');
my $tea_time_rs = $schema->resultset('TeaTime');
my $contact_rs = $schema->resultset('Contact');
my $event_type_rs = $schema->resultset('EventType');

sub tea_time_rs { $tea_time_rs }

1;
