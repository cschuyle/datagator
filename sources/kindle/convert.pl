#!/usr/bin/env perl

# Input file should be is copy-pasted from Amazon Manage Your Content and Devices
# Content page, which at the moent results in a file that looks like this:

#  ...
#  Mind on Maps: Navigate your thoughts methodically with digital mind maps
#  Antti HallaJuly 3, 2020
#  0
#  0

use strict;
use warnings;

$#ARGV == 3 or die "Usage: $0 Trove-ID Trove-Short-Name Trove-Name Input-File\n";

my ($trove_id, $short_name, $name, $input_file) = @ARGV;

my $verbose = 0;

my @titles = ();

open(IN, "grep -v ^READ\\\$ \"$input_file\" |") or die "Can't open pipe: $!";

# The First Kingdom Vol. 1: The Birth of Tundran
# Jack Katz
# Borrowed on September 8, 2023
# -OR-
# Acquired on September 8, 2023
# Return this book
# In
# 2
# Devices
# Deliver or Remove from Device
# Delete

my ($title, $author, $date, $borrowed, $read, $update_available, $state, $warnings);
$state = 'TITLE';
while (<IN>) {

    chomp;

    if (/^\s*$/) {
        $state = 'TITLE';
        $read = 'false';
        $update_available = 'false';
        next;
    }
    next if /^Deliver or Remove/;
    next if /^This title is unavailable/;
    next if /^Return this book/;
    next if /^Delete$/;
    next if /^More actions$/;
    next if /^In$/;
    next if /^Devices?$/;
    next if /^SAMPLE/;

    # TODO output records and include all data (date, borrowed, read, update_available)

    if (/^(Borrowed|Acquired) on ((Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec).*)/) {
        $borrowed = $1 eq 'Borrowed' ? 'true' : 'false';
        $date = $2;
        push @titles, "\"$title - $author\"";
        if ($state ne 'DATE') {
            print STDERR "WARNING: State should have been 'DATE' but is '$state'\n";
            $warnings = 'true';
        }
        next;
    }

    if ($state eq 'TITLE') {
        $title = $_;
        $title =~ s/"/\\"/g;
        print STDERR "TITLE $title\n" if $verbose;
        $state = 'AUTHOR';
        next;
    }

    if ($state eq 'AUTHOR') {
        $author = $_;
        $author =~ s/"/\\"/g;
        print STDERR "AUTHOR $author\n" if $verbose;
        $state = 'DATE';
        next;
    }

    if (/^READ$/) {
        $read = 'true';
        next;
    }

    if (/^Update Available$/) {
        $update_available = 'true';
        next;
    }

    if($_  =~ /^(\d+)\s*$/) {
        my $val = $1;
        if($val > 5) { # 5 devices? seems legit
            print STDERR "Unexpected line $_, which MIGHT be a title consisting only of digits, so we'll let that pass\n";
        }
    } else {
        print STDERR "WARNING: Unexpected line: '$_'\n";
        $warnings = 'true';
    }
}

if ($warnings) {
    print STDERR "Cowardly refusing to succeed because the warnings probably? resulted in inaccurate data\n";
    die;
}
my $titles_list = join ",\n", @titles;
print <<EOF;
{
  "id": "$trove_id",
  "name": "$name",
  "shortName": "$short_name",
  "titles": [
  $titles_list
  ]
}
EOF
