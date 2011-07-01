use inc::Module::Install;

name 'teatime';
version 0.1;
requires 'DBIx::Class';
requires 'DBIx::Class::Helpers';
requires 'Starman';
requires 'App::Cmd';
requires 'Web::Simple';
requires 'JSON';
requires 'Time::Duration';
requires 'List::Util::WeightedChoice';
requires 'parent';
requires 'Plack';
requires 'AnyEvent';
requires 'Term::ReadKey';
requires 'DBIx::Class::Candy';
requires 'DBIx::Class::TimeStamp';
requires 'List::Util';
requires 'File::HomeDir';
requires 'SQL::Translator';
requires 'Net::Twitter::Lite';

install_script glob('script/*.pl');
auto_install;
WriteAll;
