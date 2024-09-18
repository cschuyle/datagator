#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

for my $argv (@ARGV) {
    while($argv =~ /(PP-\d{3,})/g) {
        print "$1\n";
    }
}