package Tie::Amazon::S3;

use warnings;
use strict;

use Net::Amazon::S3;

=head1 NAME

Tie::Amazon::S3 - tie Amazon S3 buckets to Perl hashes

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';
our @ISA = qw(Net::Amazon::S3);

=head1 SYNOPSIS

    use Tie::Amazon::S3;

    tie my %bucket, 'Tie::Amazon::S3', 'my-amazon-aws-id',
        'my-amazon-aws-secret', 'my-amazon-s3-bucket';

    $t{testfile} = 'this is a testfile';
    print $t{testfile};
    ...

=head1 METHODS

=head2 TIEHASH

Constructor for tying a L<Net::Amazon::S3> object to a Perl hash.

=cut

sub TIEHASH {
    my ( $class, $id, $key, $bucket ) = @_;
    my $self = $class->SUPER::new(
        {
            aws_access_key_id => $id,
            aws_secret_access_key => $key,
        },
    );
    $self->{BUCKET} = $self->bucket($bucket);
    bless $self => $class;
}

=head2 STORE

Store some scalar into an S3 bucket (Perl hash) key.

=cut

sub STORE {
    my ( $self, $key, $value ) = @_;
    $self->{BUCKET}->add_key( $key, $value );
}

=head2 FETCH

Fetch an S3 bucket key.

=cut

sub FETCH {
    my ( $self, $key ) = @_;
    if ( $self->{BUCKET}->head_key( $key ) ) {
        return $self->{BUCKET}->get_key( $key )->{value};
    } else {
        return undef;
    }
}

=head2 EXISTS

Check if a given key exists in the bucket.

=cut

sub EXISTS {
    my ( $self, $key ) = @_;
    defined $self->{BUCKET}->head_key( $key );
}

=head2 DELETE

Delete a key from the bucket.

=cut

sub DELETE {
    my ( $self, $key ) = @_;
    # emulate native delete, returning whatever FETCH returned for this
    # key
    my $value = $self->FETCH( $key );
    $self->{BUCKET}->delete_key( $key );
    return $value;
}

=head2 CLEAR

Clear the bucket of keys.

=cut

sub CLEAR {
    my ( $self ) = shift;
    my $response = $self->{BUCKET}->list_all
        or die $self->err . ": " . $self->errstr;
    foreach my $key ( @{ $response->{keys} } ) {
        $self->DELETE( $key->{key} );
    }
}

=head1 AUTHOR

Zak B. Elep, C<< <zakame at spunge.org> >>

=head1 BUGS

Please report any bugs or feature requests to

    C<bug-tie-amazon-s3 at rt.cpan.org>,

or through the web interface at

    L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Tie-Amazon-S3>.

I will be notified, and then you'll automatically be notified of
progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Tie::Amazon::S3


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Tie-Amazon-S3>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Tie-Amazon-S3>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Tie-Amazon-S3>

=item * Search CPAN

L<http://search.cpan.org/dist/Tie-Amazon-S3>

=item * The Net::Amazon::S3 module

L<Net::Amazon::S3>

=item * Amazon's Simple Storage Service

L<http://s3.amazonaws.com>

=back


=head1 ACKNOWLEDGEMENTS

Leon Brocard, Brad Fitzpatrick, and the AWS programmers for their work.


=head1 COPYRIGHT & LICENSE

Copyright 2007 Zak B. Elep.

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

Except as contained in this notice, the name(s) of the above
copyright holders shall not be used in advertising or otherwise to
promote the sale, use or other dealings in this Software without
prior written authorization.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.


=cut

1; # End of Tie::Amazon::S3
