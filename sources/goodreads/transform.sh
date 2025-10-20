#!/usr/bin/env bash
set -o errexit # set -e
set -o nounset # set -u
set -o pipefail
# set -o xtrace # set -x
## Boilerplate
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" # where does this script live
rootdir="$scriptdir/../.." # repo root
source "$rootdir/shared/functions.sh" # shared functions

trovedir="$scriptdir/output"
tmpdir="$scriptdir/tmp"
mkdir -p "$trovedir"
mkdir -p "$tmpdir"

is_installed csvjson

troveid=goodreads
name='Goodreads'
shortname=$troveid

src_csv="$scriptdir/goodreads_library_export.csv"

tmp_csv="$tmpdir/$troveid-tmp.csv"
rm -f "$tmp_csv"
# -w: "whole word"
for shelf in \
  gathering-dust \
  currently-reading \
  to-read \
  read \
  ; do
    echo SHELF: $shelf 1>&2
    grep -w "$shelf" "$src_csv" >> "$tmp_csv" || true
done

out_csv="$tmpdir/$troveid.csv"
rm -f "$out_csv"
head -1 "$src_csv" > "$out_csv"
sort  "$tmp_csv" | uniq >> "$out_csv"

out_txt="$tmpdir/$troveid.txt"
csvjson "$out_csv" | jq '.[] | .Title' |sed "s/^\"//"|sed "s/\"\$//" > "$out_txt"

out_json="$tmpdir/$troveid.json"
lines2json "$out_txt" $troveid "$name" "$shortname" "$out_json"

mv "$out_json" "$trovedir/"
