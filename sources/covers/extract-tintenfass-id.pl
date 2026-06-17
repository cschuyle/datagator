#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

for my $argv (@ARGV) {
    while($argv =~ /tintenfass[\s_-]*(\d+)/gi) {
        print "$1\n";
    }
}
