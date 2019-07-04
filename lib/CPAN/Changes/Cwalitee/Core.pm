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

            return [200, "OK", "Some dates are not in the correct format, e.g. in version $v"];
        }
    }
    [200, "OK", ''];
}

$SPEC{indicator_releases_in_descending_date_order} = {
    v => 1.1,
    summary => 'Releases are ordered descendingly by its date (newest first)',
    description => <<'_',

This order is, in my opinion, the best order optimized for reading by users.

_
    args => {
    },
    'x.indicator.severity' => 2,
};
sub indicator_releases_in_descending_date_order {
    require Data::Cmp;

    my %args = @_;
    my $r = $args{r};

    my $p = $r->{parsed};
    defined $p or return [412];

    my @dates = map { $_->{date} } @{ $p->{_releases_array} // [] };
    if (grep { !defined($_) || !$_ } @dates) {
        return [412, "Some releases have unparsable dates"];
    }

    my @sorted_dates = sort { $b cmp $a } @dates;
    if (Data::Cmp::cmp_data(\@dates, \@sorted_dates) == 0) {
        return [200, "OK", ''];
    } else {
        return [200, "OK", "Releases are not ordered by descending date"];
    }
}

$SPEC{indicator_release_dates_not_future} = {
    v => 1.1,
    summary => 'No release dates are in the future',
    args => {
    },
    'x.indicator.severity' => 2,
};
sub indicator_release_dates_not_future {
    require DateTime;
    require DateTime::Format::ISO8601;

    my %args = @_;
    my $r = $args{r};

    my $p = $r->{parsed};
    defined $p or return [412];

    my @dates        = map { $_->{date} }         @{ $p->{_releases_array} // [] };
    my @parsed_dates = map { $_->{_parsed_date} } @{ $p->{_releases_array} // [] };
    if (grep { !defined($_) || !$_ } @dates) {
        return [412, "Some releases have unparsable dates"];
    }

    my $dt_now = DateTime->now(time_zone => 'UTC');
    for my $i (0..$#dates) {
        my $date = $dates[$i];
        my $parsed_date = $parsed_dates[$i];
        my $dt_rel = DateTime::Format::ISO8601->parse_datetime($date);
        if (DateTime->compare($dt_now, $dt_rel) == -1) {
            return [200, "OK", "Release date '$parsed_date' ($date) is in the future"];
        }
    }
    [200, "OK", ''];
}

# currently commented-out, not good results
#
# $SPEC{indicator_preamble_english} = {
#     v => 1.1,
#     summary => 'Preamble, if exists, is in English',
#     args => {
#     },
#     'x.indicator.severity' => 2,
# };
# sub indicator_preamble_english {
#     require Lingua::Identify;

#     my %args = @_;
#     my $r = $args{r};

#     my $p = $r->{parsed};
#     defined $p or return [412];

#     return [200, "OK", ''] unless $p->{preamble} =~ /\S/;

#     my %langs = Lingua::Identify::langof($p->{preamble});
#     return [412, "Lingua::Identify cannot detect language"] unless keys(%langs);

#     my @langs = sort { $langs{$b}<=>$langs{$a} } keys %langs;
#     my $confidence = Lingua::Identify::confidence(%langs);
#     log_trace(
#         "Lingua::Identify result: langof=%s, langs=%s, confidence=%s",
#         \%langs, \@langs, $confidence);
#     if ($langs[0] ne 'en') {
#         [200, "OK", "Language not detected as English, ".
#              sprintf("%d%% %s (confidence %.2f)",
#                      $langs{$langs[0]}*100, $langs[0], $confidence)];
#     } else {
#         [200, "OK", ''];
#     }
# }

# TODO: indicator_entries_english
# TODO: indicator_sufficient_entries_length
# TODO: indicator_version_correct_format
# TODO: indicator_entries_not_commit_logs
# TODO: indicator_entries_not_useless (e.g. 'Update/prepare Changes for v0.01')
# TODO: indicator_name_preferred (e.g. Changes and not ChangeLog.txt)
# TODO: indicator_text_not_too_wide

1;
# ABSTRACT: A collection of core indicators for CPAN Changes cwalitee
