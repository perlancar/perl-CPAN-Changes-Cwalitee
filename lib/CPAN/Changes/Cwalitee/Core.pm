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
    summary => 'Dates are parsable by CPAN::Changes',
    args => {
    },
};
sub indicator_date_parsable {
    my %args = @_;
    my $r = $args{r};

    my $p = $r->{parsed};
    defined $p or return [412];

    for my $v (sort keys %{ $p->{releases} }) {
        my $rel = $p->{releases}{$v};
        if (!defined $rel->{date} && !length $rel->{_parsed_date}) {
            return [200, "OK", "Some dates are not parsable, e.g. for version $v"];
        }
    }
    [200, "OK", ''];
}

$SPEC{indicator_date_correct_format} = {
    v => 1.1,
    summary => 'Dates are specified in the correct specified format, e.g. YYYY-MM-DD',
    description => <<'_',

Although <pm:CPAN::Changes> can parse various forms of dates, the spec states
that dates should be in the format specified by
<http://www.w3.org/TR/NOTE-datetime>, which is one of:

    YYYY
    YYYY-MM
    YYYY-MM-DD
    YYYY-MM-DD"T"hh:mm<TZD>
    YYYY-MM-DD"T"hh:mm:ss<TZD>
    YYYY-MM-DD"T"hh:mm:ss.s<TZD>

The "T" marker is optional. TZD is time zone designator (either "Z", or "+hh:mm"
or "-hh:mm").

_
    args => {
    },
};
sub indicator_date_correct_format {
    my %args = @_;
    my $r = $args{r};

    my $p = $r->{parsed};
    defined $p or return [412];

    for my $v (sort keys %{ $p->{releases} }) {
        my $rel = $p->{releases}{$v};
        unless ($rel->{_parsed_date} =~
                    /\A
                     [0-9]{4}
                     (?:-[0-9]{2}
                         (?:-[0-9]{2}
                             (?: # time part
                                 [T ]?
                                 [0-9]{2}:[0-9]{2}
                                 (?: # second
                                     :[0-9]{2}
                                     (?:\.[0-9]+)?
                                 )?
                                 (?: # time zone indicator
                                     Z | [+-][0-9]{2}:[0-9]{2}
                                 )?
                             )?
                         )?
                     )?
                     \z/x) {

            return [200, "OK", "Some dates are not in the correct format, e.g. '$rel->{_parsed_date}'"];
        }
    }
    [200, "OK", ''];
}

# $SPEC{indicator_releases_in_descending_date_order} = {
#     v => 1.1,
#     summary => 'Releases are ordered descendingly by its date (newest first)',
#     description => <<'_',

# This order is, in my opinion, the best order optimized for reading by users.

# _
#     args => {
#     },
#     'x.indicator.severity' => 2,
# };
# sub indicator_releases_in_descending_date_order {
#     my %args = @_;
#     my $r = $args{r};

#     my $p = $r->{parsed};
#     defined $p or return [412];

#     for my $v (sort keys %{ $p->{releases} }) {
#         my $rel = $p->{releases}{$v};
#     }
#     [200, "OK", ''];
# }

# TODO: indicator_date_not_future
# TODO: indicator_preamble_english
# TODO: indicator_entries_english

1;
# ABSTRACT: A collection of core indicators for CPAN Changes cwalitee
