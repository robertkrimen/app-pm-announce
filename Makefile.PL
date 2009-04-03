use inc::Module::Install;

name     'App-PM-Announce';
all_from 'lib/App/PM/Announce.pm';
author   'Robert Krimen <rkrimen@cpan.org>';
license  'perl';

resources repository => 'http://github.com/robertkrimen/app-pm-announce/tree/master';

{
    require ExtUtils::MakeMaker;
    use strict;
    no strict 'refs';

    my $libscan = \&{"ExtUtils::MM_Any::libscan"};
    *{"ExtUtils::MM_Any::libscan"} = sub {
        return '' unless $libscan->(@_);
        return '' if $_[1] =~ /\.sw[p-z]$/;
        return $_[1];
    };
}

{
    map { my ($pk, $vr) = split m/\s/; build_requires $pk => $vr || 0 } grep { ! /^\s*#/ } split m/\n/, <<_END_;
Test::Most
_END_

    map { my ($pk, $vr) = split m/\s/; requires $pk => $vr || 0 } grep { ! /^\s*#/ } split m/\n/, <<_END_;
Config::JFDI
Moose
WWW::Mechanize
Getopt::Chain
File::HomeDir
Config::General
String::Util
HTML::TreeBuilder
MooseX::LogDispatch
_END_
}

if (-e 'inc/.author') {
    my $all_from = join '/', 'lib', split m/-/, name . '.pm';
    `perldoc -tF $all_from > README` if ! -e 'README' || (stat $all_from)[9] > (stat 'README')[9];
}


auto_install;

WriteAll;

