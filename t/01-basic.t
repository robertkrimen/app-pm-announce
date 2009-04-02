#!/usr/bin/perl -w

use strict;
use warnings;

use Test::Most;

plan qw/no_plan/;

use App::PM::Announce;

my $app = App::PM::Announce->new;
$app->startup;

ok($app);
