#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 6;

BEGIN {
    use_ok('JavaScript::JSCore');
}

ok( exists $::JavaScript::JSCore::{'Value::'}, 'Value:: namespace gets created' );
ok( exists $::JavaScript::JSCore::{'Object::'}, 'Object:: namespace gets created' );
ok( exists $::JavaScript::JSCore::{'Context::'}, 'Context:: namespace gets created' );
ok( exists $::JavaScript::JSCore::{'Class::'}, 'Class:: namespace gets created' );
ok( exists $::JavaScript::JSCore::Context::{'Global::'}, 'Context::Global:: namespace gets created' );
