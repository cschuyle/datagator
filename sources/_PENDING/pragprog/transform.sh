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

list_id="pragprog"
output_file="$trovedir/$list_id.json"

perl "$scriptdir/convert.pl" $list_id "ProgProg" "Pragmatic Programmers eBooks" "$scriptdir/$list_id.txt" > "$output_file"
