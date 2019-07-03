package CPAN::Changes::Subclass::Cwalitee;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use parent qw(CPAN::Changes);

sub add_release {
    my $self = shift;

    for my $release ( @_ ) {
        my $new = Scalar::Util::blessed $release ? $release
            : CPAN::Changes::Release->new( %$release );
        $self->{ releases }->{ $new->version } = $new;

        # we also push to an array
        $self->{ _releases_array } //= [];
        push @{ $self->{_releases_array} }, $new;
    }
}

1;
# ABSTRACT: CPAN::Changes subclass for CPAN::Changes::Cwalitee

=head1 SYNOPSIS

Use as you would L<CPAN::Changes>.


=head1 DESCRIPTION

This subclass currently does the following:

=over

=item * In add_release, also store the releases in the order received

We want to know the original order of releases in the file.

=back
