#!/usr/bin/env perl

# Input file should be is copy-pasted from pragprog.com "my orders" link (which goes to https://transactions.sendowl.com/customer_accounts/123456)

use strict;
use warnings;

$#ARGV == 3 or die "Usage: $0 Trove-ID Trove-Short-Name Trove-Name Input-File\n";

my ($trove_id, $short_name, $name, $input_file) = @ARGV;

my @titles = ();

open(IN, "grep -v ^READ\\\$ \"$input_file\" |") or die "Can't open pipe: $!";

my ($title);
while (<IN>) {
    if( /^\d+\s+(.*)\s+\d\d\d\d-\d\d-\d\d\s+download$/) {
        $title = $1;
        push @titles, "\"$title\""
    }

}
my $titles = join ",\n", @titles;
print <<EOF;
{
  "id": "$trove_id",
  "name": "$name",
  "shortName": "$short_name",
  "titles": [
  $titles
  ]
}
EOF
