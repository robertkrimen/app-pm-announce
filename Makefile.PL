use inc::Module::Install;

name     'App-PM-Announce';
all_from 'lib/App/PM/Announce.pm';
author   'Robert Krimen <rkrimen@cpan.org>';
license  'perl';

build_requires 'Test::More';

auto_install;

WriteAll;

