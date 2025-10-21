#!/usr/bin/env bash
set -o errexit # set -e
set -o nounset # set -u
set -o pipefail
## Boilerplate
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" # where does this script live
rootdir="$scriptdir/../.." # repo root
source "$rootdir/ci/bin/functions.sh" # shared functions

mkdir -p "$trovedir"

csv_header="title,year,rated,duration,rating"
tsv_header=$(printf "title\tyear\trated\tduration\trating")
tsv_file="dvdinbox.tsv"
head="$(head -1 "$tsv_file")"
if [[ "$tsv_header" != "$head" ]]; then
    echo "Headers don't match for $tsv_file
    |$head|
    |$tsv_header|
"
    exit 1
fi
troveid="dvdinbox"
name="DVDInbox Queue"
shortname="DVDInbox"

csv_file="$tmpdir/$troveid.csv"
echo $csv_header > "$csv_file"
tail -n+2 "$tsv_file" | csvformat -t -Q '"' -U 1 >> "$csv_file"
echo "Wrote '$csv_file'" 1>&2

tmp_json_file="$tmpdir/$troveid.tmp.json"
# --no-inference or else years are output like: 2004.0
csvjson --no-inference "$csv_file" > "$tmp_json_file"
echo "Wrote '$tmp_json_file'" 1>&2

output_txt_file="$tmpdir/$troveid-simple.txt"
cat "$tmp_json_file" | jq -r '.[] | "\(.title) (\(.year))"' > "$output_txt_file"
echo "Wrote '$output_txt_file'" 1>&2

output_json="$trovedir/$troveid.json"
lines2json "$output_txt_file" "$troveid" "$name" "$shortname" "$output_json"

echo "Wrote final output to '$output_json'" 1>&2
