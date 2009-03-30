#!/usr/bin/perl

use strict;
use warnings;

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

# s*p*g***t
