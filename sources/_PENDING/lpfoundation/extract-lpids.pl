#!/usr/bin/env perl
while(<>) {

    # SAMPLE INPUT LINE - a URL of an LP Foundation individual book record.
    # https://petit-prince-collection.com/lang/show_livre.php?lang=en&id=6702
    
    if(/show_livre\.php\?lang=en&id=(\d+)/) {
        my $id = $1;
        print("PP-$id\n");
    }
}
