use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
        PREREQ_FATA => 1,
        PREREQ_PM   => {
            'ExtUtils::PkgConfig' => 0,
        },
) unless eval q[use ExtUtils::PkgConfig; 1];

my %pkginfo = ExtUtils::PkgConfig->find('webkit-1.0');

WriteMakefile(
        NAME    => 'JavaScript::JSCore',
        VERSION_FROM => 'lib/JavaScript/JSCore.pm',
        ABSTRACT_FROM => 'lib/JavaScript/JSCore.pm',
        XSPROTOARG      => '-noprototypes',
        INC             => '-Wall -Werror -Iperl_glue '. $pkginfo{cflags},
        LIBS            => $pkginfo{libs},
        do {
            my (@clean, @OBJECT, %XS);

            for my $xs (<xs/*.xs>) {
                (my $c = $xs) =~ s/\.xs/.c/i;
                (my $o = $xs) =~ s/\.xs/\$(OBJ_EXT)/i;

                $XS{$xs} = $c;
                push @OBJECT, $o;
                push @clean, $o;
            }

            for my $c (<perl_glue/*.c>) {
                (my $o = $c) =~ s/\.c/\$(OBJ_EXT)/i;

                push @OBJECT, $o;
                push @clean, $o;
            }

            clean   => { FILES => join(q[ ], @clean) },
            OBJECT  => join(q[ ], @OBJECT),
            XS      => \%XS,
        },
);

package MY;

sub const_cccmd {
    my $inherited = shift->SUPER::const_cccmd(@_);
    return '' unless $inherited;

    $inherited .= ' -o $@';

    return $inherited;
}
