#!/usr/bin/env perl

my $title;
my $year;
my $rated;
my $duration;
my $rating;
my $state = '';
my $first = 1;

while (<>) {
    chomp;
    if (/^(\d{4})/) {
        $year = $1;
        $state = 1;
        next;
    }

    if ($state == 1 && /^([A-Z\d-]+)$/) {
        $rated = $1;
        next;
    }

    if ($state == 1 && /^Rated ([\d\.]+)/) {
        $rating = $1;
        if ($first) {
            print <<"EOF";
title\tyear\trated\tduration\trating
EOF
            $first = 0;
        }
        print <<"EOF";
$title\t$year\t$rated\t$duration\t$rating
EOF
        $state = '';
        next;
    }

    if ($state == 1 && /^(\d+h?\s?\d+m)$/) {
        $duration = $1;
        next;
    }

    if ($state == "") {
        $title = $_;
    }
}