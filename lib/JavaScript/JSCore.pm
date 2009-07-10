use strict;
use warnings;

package JavaScript::JSCore;

our $VERSION = '0.01';
our @ISA;

eval {
    require XSLoader;
    XSLoader::load( __PACKAGE__, $VERSION );
    1;
} or do {
    require DynaLoader;
    push @ISA, 'DynaLoader';
    __PACKAGE__->bootstrap($VERSION);
};

1;
