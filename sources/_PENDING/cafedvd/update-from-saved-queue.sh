#!/usr/bin/env bash
set -o errexit # set -e
set -o pipefail
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$scriptdir/../../ci/bin/functions.sh"

is_installed xmlstarlet

cafedvd_filename="Cafe DVD -- online dvd rental - movie rentals by mail.html"
downloads_filename="$HOME/Downloads/$cafedvd_filename"
scriptdir_filename="$scriptdir/$cafedvd_filename"
output_textfile="$scriptdir/cafedvd-queue.txt"

if [[ ! -f "$downloads_filename" ]]; then
  echo "Expected file '$downloads_filename' does not exist"
  exit 1
fi

if [[ -f "$scriptdir_filename" ]]; then
  echo "Deleting existing file '$scriptdir_filename'"
  rm "$scriptdir_filename"
fi

cp "$downloads_filename" "$scriptdir_filname"

 #<span class="d-inline-block movie-popover" tabindex="0" data-bs-toggle="popover" data-bs-custom-class="popover-w400" data-dvd-movieid="4055713" data-dvd-title="The Secret Life of Pets" data-dvd-year="2016" data-dvd-rating="PG" data-dvd-duration="1h 30m" data-dvd-summary="-" data-dvd-cast="[&quot;Louis C.K.&quot;,&quot; Eric Stonestreet&quot;,&quot; Kevin Hart&quot;,&quot; Jenny Slate&quot;,&quot; Ellie Kemper&quot;,&quot; Albert Brooks&quot;,&quot; Lake Bell&quot;,&quot; Dana Carvey&quot;,&quot; Hannibal Buress&quot;,&quot; Bobby Moynihan&quot;,&quot; Chris Renaud&quot;,&quot; Steve Coogan&quot;,&quot; Michael Beattie&quot;,&quot; Sandra Echeverria&quot;,&quot; Jaime Camil&quot;]" data-dvd-director="[&quot;Chris Renaud&quot;]" data-dvd-genre="[&quot;Children &amp; Family&quot;,&quot; Family Animation&quot;,&quot; Family Comedies&quot;,&quot; Animal Tales&quot;]" data-dvd-format="[&quot;DVD&quot;]" data-dvd-userreviewrate="3.58" data-dvd-myreviewrate="0"><a href="https://www.cafedvd.com/newcode/4055713"><img src="./Cafe DVD -- online dvd rental - movie rentals by mail_files/4055713th_.jpg"></a></span></div>

grep '<span class="d-inline-block movie-popover"' "$scriptdir_filename" \
  | perl -ne 'if (/data-dvd-title="(.*?)"\s+data-dvd-year="(.*?)"/) { print "$1 ($2)\n"; }' \
  | xmlstarlet unesc \
  > "$output_textfile"

echo "Created output file '$output_textfile'"

