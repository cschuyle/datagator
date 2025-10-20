# Amazon Wish List Mechanical Turk Scraper

Read instructions in `scrape-list-page.js`

USAGE

1. Log into Amazon
1. Go to each wishlist in turn, and scroll all the way to the end (the page is infinite-scrolling).
   1. Paste the code from  `scrape-list-page.js` in the console in the dev console in the browser
   1. copy the resulting web page, save it as EXPORTED.tsv.'

Test the conversion:

```console
./transform.sh
```

Inspect the output file for correctness.
