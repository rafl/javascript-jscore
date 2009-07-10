#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 3;
use JavaScript::JSCore;

use Devel::Peek;

my $ctx = JavaScript::JSCore::Context::Global->create;

isa_ok($ctx, 'JavaScript::JSCore::Context::Global');
isa_ok($ctx, 'JavaScript::JSCore::Context');

my $var = $ctx->create_value('boolean');
isa_ok($var, 'JavaScript::JSCore::Value');
