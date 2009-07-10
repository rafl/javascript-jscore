#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;
use Test::More tests => 3;
use JavaScript::JSCore;

sub cb_for {
    my ($name) = @_;

    return sub {
        diag $name;
    };
}

my $class = JavaScript::JSCore::Class->new({
        name => 'myclass',
        map { ($_ => cb_for($_)) } qw/
            initialize
            finalize
            has_property
            get_property
            set_property
            delete_property
            get_property_names
            call_as_function
            call_as_constructor
            has_instance
            convert_to_type
        /,
});
isa_ok($class, 'JavaScript::JSCore::Class');

my $ctx = JavaScript::JSCore::Context::Global->create;
isa_ok($ctx, 'JavaScript::JSCore::Context::Global');

use Devel::Peek;

{
    {
        my $obj = $class->create_instance($ctx);
        Dump $obj;
        isa_ok($obj, 'JavaScript::JSCore::Object');

        say 1;
        Dump $ctx;
        #$ctx->garbage_collect;
        Dump $ctx;
    }
    say 2;
}

say 3;
#$ctx->garbage_collect;
