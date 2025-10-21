#!/usr/bin/env bash
set -o errexit # set -e
set -o nounset # set -u
set -o pipefail
## Boilerplate
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" # where does this script live
rootdir="$scriptdir/../.." # repo root
source "$rootdir/ci/bin/functions.sh" # shared functions

mkdir -p "$trovedir"
rm -f "$tmpdir"/*.json

input_file="$scriptdir/domains.csv"
list_id="nic.sh-and-101domain"
list_name="nic.sh & 101domain"
list_short_name="nic.sh/101domain"

output_file="$trovedir/$list_id.json"

perl -pi -e 's/ \(Punycode\)//g' "$scriptdir/domains.csv"

csvjson -H "$input_file" \
  | jq '.[] | .a' \
  | sed "s/\"\$//" \
  | sed "s/^\"//" \
  | tr '[:upper:]' '[:lower:]' \
  > "$tmpdir/nic.sh.txt"

lines2json "$tmpdir/nic.sh.txt" "$list_id" "$list_name" "$list_short_name" "$output_file"

