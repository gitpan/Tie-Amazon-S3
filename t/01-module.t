#!perl -T

use warnings;
use strict;

use Test::More;
use Tie::Amazon::S3;

unless ( $ENV{AMAZON_S3_EXPENSIVE_TESTS} ) {
    plan skip_all => 'Testing this module for real costs money.';
} else {
    plan tests => 13;
}

my $aws_access_key_id = $ENV{AWS_ACCESS_KEY_ID};
my $aws_secret_access_key = $ENV{AWS_ACCESS_KEY_SECRET};
my $aws_s3_bucket = $ENV{AWS_ACCESS_S3_BUCKET};

can_ok 'Tie::Amazon::S3', qw(TIEHASH STORE FETCH EXISTS DELETE CLEAR SCALAR s3_croak);

my $t = Tie::Amazon::S3->TIEHASH(
    $aws_access_key_id, $aws_secret_access_key, $aws_s3_bucket
);
isa_ok $t, 'Tie::Amazon::S3';

is ref($t->STORE('foo', 'some code')), 'CODE',
    'STORE returns a coderef to the value of the key stored to S3';

$t->STORE('bar', 'something else');
is $t->FETCH('bar'), 'something else',
    'FETCH gets the key from S3';

isnt $t->EXISTS('foo'), undef,
    'EXISTS checks if key is in the S3 bucket';

is $t->SCALAR(), 2,
    'SCALAR returns the number of keys in the S3 bucket';

is $t->FIRSTKEY(), 'bar',
    'FIRSTKEY gets the first key in the bucket';
is $t->NEXTKEY(), 'foo',
    'NEXTKEY gets the key after the previous FIRSTKEY/NEXTKEY call';

is $t->DELETE('foo'), 'some code',
    'DELETE returns the deleted value of the key from S3';
is $t->EXISTS('foo'), '',
    'DELETEd key no longer EXISTS';

is $t->CLEAR(), '',
    'CLEAR removes all keys from S3';
is $t->EXISTS('bar'), '',
    'key removed by CLEAR no longer EXISTS';

eval '$t->FETCH("some-nonexistent-key")';
isnt $@, undef,
    's3_croak should croak errors from S3';

