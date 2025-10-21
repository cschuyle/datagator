#!/usr/bin/env perl

# Input file should be is copy-pasted from <manning.com/dashboard>, the list under "your products".
# So far the following algorithm has been successful:
# - delete blank lines
# - delete 'Foreword by' lines
# - delete 'canceled:' lines
#
# But, YMMV

use strict;
use warnings FATAL => 'all';

# TODO Detect missing and tell how to install them
# cpan App::cpanminus
# cpan JSON

use JSON;

# print "ARGV $#ARGV\n";
$#ARGV == -1 or die "Usage: $0\n";

my ($trove_id, $short_name, $name, $input_file) = ("manning", "Manning", "Manning eBooks", "./manning.txt");

my @items = ();

open(IN, "grep -v ^READ\\\$ \"$input_file\" |") or die "Can't open pipe: $!";

my ($title, $author, $line_num);
$line_num = -1;

while (<IN>) {
    next if /^\s*$/;
    next if /^Foreword by/;
    next if /^canceled:/;
    ++$line_num;
    if ($line_num % 3 == 0) {
        chomp;
        $title = $_;
    }
    if ($line_num % 3 == 1) {
        chomp;
        $author = $_;
    }

    if ($line_num % 3 == 2) {
        my $item = {
            "littlePrinceItem" => {
                "title"  => $title,
                "author" => $author,
                "format" => "eBook",
                "language" => "English", # This sucks, but until we get the data input formats all ironed out let's not worry about it
                "smallImageUrl" => "small-image-url", # OK this is getting ridiculous
                "largeImageUrl" => "large-image-url" # Gotta at least make tests
            }
        };
        push @items, $item;
        # print STDERR "Added $item\n";
    }
}

open OUT, ">./$trove_id.json";
my @item_objs = map {to_json($_)} @items;
my $items = join(",\n", @item_objs);

print OUT <<EOF;
{
  "id": "$trove_id",
  "name": "$name",
  "shortName": "$short_name",
  "items": [
  $items
  ]
}
EOF
