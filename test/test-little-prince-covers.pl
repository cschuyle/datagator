#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

my $DEBUG =  undef;

sub trim {
    my ($in) = @_;
    $in =~ s/\s+$//;
    $in =~ s/^\s+//;
    return $in;
}

sub unquote {
    my ($in) = @_;
    $in =~ s/"$//;
    $in =~ s/^"//;
    return $in
}

sub test_filename {
    my ($filename, $title, $language) = @_;
    $filename =~ s/'/'"'"'/g;
    print STDERR "FILENAME $filename \n" if $DEBUG;
    my @actual = `./title-language.pl '$filename'`;
    my $actual_title = unquote(trim($actual[0]));
    my $actual_language = unquote(trim($actual[1]));

    $actual_title eq $title or die "Input filename |$filename| :: Title- expected |$title|, got |$actual_title|";
    $actual_language eq $language or die "Input filename |$filename| :: Language- expected |$language|, got |$actual_language|";
}

test_filename(
    "little prince - title - language",
    "title (The Little Prince, in language)",
    "language"
);

test_filename(
    "title - little prince - language",
    "title (The Little Prince, in language)",
    "language"
);

test_filename(
    "little prince language",
    "The Little Prince, in language",
    "language"
);

test_filename(
    "little prince - language",
    "The Little Prince, in language",
    "language"
);

test_filename(
    "Plain old title",
    "Plain old title",
    "Unknown"
);

test_filename(
    "A super book in many languages - you won't believe #7",
    "A super book in many languages - you won't believe #7",
    "Unknown"
);

