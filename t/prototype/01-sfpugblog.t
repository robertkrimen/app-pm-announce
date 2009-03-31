#!/usr/bin/perl

use strict;
use warnings;

use Test::Most;
plan qw/no_plan/;

use WWW::Mechanize;
use HTTP::Request::Common qw/POST/;

my $agent = WWW::Mechanize->new;

$agent->request(
    POST "http://sf.pm.org/cgi-bin/greymatter/gm.cgi", {
        authorname => 'Test',
        authorpassword => '',
        newentrysubject => 'Test subject',
        newentrymaintext => 'Test maintext',
        newentrymoretext => '',
        newentryallowkarma => 'no',
        newentryallowcomments => 'no',
        newentrystayattop => 'no',
        thomas => 'Add This Entry',
    },
);

ok(1);

# s*p*g***t
