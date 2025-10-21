#!/usr/bin/env perl
while(<>) {
    if(/lang=en&id=(\d+)">(.*?)<\/a>/) {
        my $id = $1;
        my $language = $2;

        $language =~ s/&nbsp;/ /g;

        # <em>...</em> --> ' - '
        $language =~ s/<em>/ - /g;
        $language =~ s/<\/?\w+>//g;

        # Constructed languages have this sign
        $language =~ s/&#9788;/ - constructed language/g;
        
        # Clean up
        $language =~ s/\s+/ /g;
        $language =~ s/\s+-\s+$//;
        $language =~ s/\s+$//;

        print("$id $language\n");
    }
}
