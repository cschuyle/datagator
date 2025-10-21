# The Little Prince Foundation

https://petit-prince-collection.com/lang/intro.php?lang=en

## Extract stuff

Given a file containing URLs of LP books:
```
extract-lpids.pl sample-book-URLs-from-lp-foundation.txt
```
... and that is suitable as input to `dg`, so this will download a boatload of info:
```
dg $(../extract-lpids.pl sample-book-URLs-from-lp-foundation.txt)
```

Given the downloaded file, print a report of the languages and their IDs
```
./extract-languages.pl collection-LANGUAGES.html
```