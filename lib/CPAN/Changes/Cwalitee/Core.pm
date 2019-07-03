package CPAN::Changes::Cwalitee::Core;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;
use Log::ger;

#use CPAN::Changes::CwaliteeCommon;

our %SPEC;

$SPEC{indicator_parsable} = {
    v => 1.1,
    summary => 'Parseable by CPAN::Changes',
    args => {
    },
    #'x.indicator.error'    => '', #
    #'x.indicator.remedy'   => '', #
    #'x.indicator.severity' => '', # 1-5
    #'x.indicator.status'   => '', # experimental, stable*
    'x.indicator.priority' => 10,
};
sub indicator_parsable {
    my %args = @_;
    my $r = $args{r};

    defined($r->{parsed}) ?
        [200, "OK", ''] : [200, "OK", 'Changes is not parsable'];
}

$SPEC{indicator_date_parsable} = {
    v => 1.1,
    args => {
    },
};
sub indicator_date_parsable {
    my %args = @_;
    my $r = $args{r};

    my $p = $r->{parsed};
    defined $p or return [412];

    for my $rel (@{ $p->{releases} }) {
        if (length $rel->{date} && !$rel->{_parsed_date}) {
            return [200, "OK", "Some dates are not parsable, e.g. $rel->{date}"];
        }
    }
    [200, "OK", ''];
}

1;
# ABSTRACT: A collection of core indicators for CPAN Changes cwalitee
