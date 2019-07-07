package CPAN::Changes::Cwalitee;

# DATE
# VERSION

use 5.010001;
use strict 'subs', 'vars';
use warnings;
use Log::ger;

use Cwalitee::Common;

use Exporter qw(import);
our @EXPORT_OK = qw(
                       calc_cpan_changes_cwalitee
                       list_cpan_changes_cwalitee_indicators
               );

our %SPEC;

$SPEC{list_cpan_changes_cwalitee_indicators} = {
    v => 1.1,
    args => {
        Cwalitee::Common::args_list('CPAN::Changes::'),
    },
};
sub list_cpan_changes_cwalitee_indicators {
    my %args = @_;

    Cwalitee::Common::list_cwalitee_indicators(
        prefix => 'CPAN::Changes::',
        %args,
    );
}

$SPEC{calc_cpan_changes_cwalitee} = {
    v => 1.1,
    args => {
        Cwalitee::Common::args_calc('CPAN::Changes::'),
        path => {
            schema => 'pathname*',
            req => 1,
        },
    },
};
sub calc_cpan_changes_cwalitee {
    require File::Slurper;

    my %fargs = @_;
    my $path = delete $fargs{path};

    my $parse_attempted;
    Cwalitee::Common::calc_cwalitee(
        prefix => 'CPAN::Changes::',
        %fargs,
        code_init_r => sub {
            return {
                path => $path,
                file_content => File::Slurper::read_text($path),
            };
        },
        code_fixup_r => sub {
            my %cargs = @_;
            my $ind = $cargs{indicator};
            my $r   = $cargs{r};

            if ($ind->{priority} > 1 && !$parse_attempted++) {
                require CPAN::Changes::Subclass::Cwalitee;
                eval {
                    $r->{parsed} = CPAN::Changes::Subclass::Cwalitee->load_string(
                        $r->{file_content});
                };
            }
        },
    );
}

1;
# ABSTRACT: Calculate the cwalitee of your CPAN Changes file

=head1 SYNOPSIS

 use CPAN::Changes::Cwalitee qw(
     calc_cpan_changes_cwalitee
     list_cpan_changes_cwalitee_indicators
 );

 my $res = calc_cpan_changes_cwalitee(
     path => 'Changes',
 );


=head1 DESCRIPTION

B<What is CPAN Changes cwalitee?> A metric to attempt to gauge the quality of
your CPAN Changes file. Since actual quality is hard to measure, this metric is
called a "cwalitee" instead. The cwalitee concept follows "kwalitee" [1] which
is specifically to measure the quality of CPAN distribution. I pick a different
spelling to avoid confusion with kwalitee. And unlike kwalitee, the unqualified
term "cwalitee" does not refer to a specific, particular subject. There can be
"CPAN Changes cwalitee" (which is handled by this module), "module abstract
cwalitee", and so on.


=head1 INTERNAL NOTES

B<Indicator priority.> At priority 10, Changes file is parsed using
CPAN::Changes and the result # it put in 'parsed' key.


=head1 SEE ALSO

[1] L<https://cpants.cpanauthors.org/>

L<App::CPANChangesCwaliteeUtils> for the CLI's.

=cut
