#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

# cpan App::cpanminus
# cpan Text::Autoformat

system("perldoc -l Text::Autoformat >&/dev/null");

if($? != 0) {
    die <<EOF;
    You need to install the Text:Autoformat Perl module. Try:
\$ cpan
(answer 'yes' to the question about setting up if this is the first time you're running cpan)
cpan[1]> install Text::Autoformat
cpan[2]> exit 
EOF
}

use Text::Autoformat;

sub trim {
    my ($in) = @_;
    $in =~ s/\s+$//;
    $in =~ s/^\s+//;
    return $in;
}

sub just_lp {
    my ($title) = @_;
    return defined $title && $title =~ /^(the\W*)?little\W*prince$/i
}

sub has_lp {
    my ($title) = @_;
    return defined $title && $title =~ /(the\W*)?little\W*prince/i
}

sub titleize {

    my($words) = @_;
    return $words;
    my $title = autoformat $words, { case => 'highlight', squeeze => 0 };
    $title =~ s/\s+$//;
    return $title;
}

my $DEBUG = undef;

my $title_language = $ARGV[0];
$title_language = trim($title_language);
$title_language =~ s/\s+/ /g;

my($title, $title2_or_language, $language) = split /\s+-\s+/, $title_language;

($language = undef) if defined $language && $language eq '';

my $title2 = undef;
if(defined $language) {
    $title = titleize($title);
    $title2 = titleize($title2_or_language);
    $language = titleize($language);
} else {
    $title = titleize($title);
    $language = titleize($title2_or_language);
}

($title2 = undef) if defined $title2 && $title2 eq '';
($language = undef) if defined $language && $language eq '';

$title = trim($title) if defined $title;
$title2 = trim($title2) if defined $title2;
$language = trim($language) if defined $language;
$title2_or_language = trim($title2_or_language) if defined $title2_or_language;

if($DEBUG) {

    my $p_title = $title // '';
    my $p_title2 = $title2 // '';
    my $p_title2_or_language = $title2_or_language // '';
    my $p_language = $language // '';

    print STDERR <<"EOF";

title_language     | $title_language
title              | $p_title
title2             | $p_title2
title2_or_language | $p_title2_or_language
language           | $p_language
EOF
}
# the little prince - kis herceg - hungarian
if(just_lp($title) && defined $title2) {
    $title = "$title2 (The Little Prince, in $language)"
}

# kis herceg - the little prince - hungarian
elsif(defined $title && just_lp($title2)) {
    print STDERR "CASE 1\n" if $DEBUG;
    $title = "$title (The Little Prince, in $language)"
}

# little prince hungarian
elsif(has_lp($title) && ! defined $language) {
    print STDERR "CASE 2\n" if $DEBUG;
    if( $title =~ /little\W+prince\s+(.*)/) {
        $language = titleize($1);
    } else {
        $language = "Unknown";
    }
    $title = "The Little Prince, in $language"
}

# little prince - hungarian
elsif(has_lp($title) && defined $language && ! defined $title2) {
    print STDERR "CASE 3\n" if $DEBUG;
    $title = "The Little Prince, in $language"
}

else {
    print STDERR "CASE 4\n" if $DEBUG;
    $title = $title_language;
    $language = 'Unknown';
}

# Scrub out chaff for Little Prince Foundation downloads
$title =~ s/\s*PP-\d+//g;
$language =~ s/\s*PP-\d+//g;

print <<"EOF";
"$title"
"$language"
EOF
