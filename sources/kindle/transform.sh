#!/usr/bin/env bash
set -o errexit # set -e
set -o nounset # set -u
set -o pipefail
## Boilerplate
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" # where does this script live
rootdir="$scriptdir/../.." # repo root
source "$rootdir/shared/functions.sh" # shared functions

trovedir="$scriptdir/output"
tmpdir="$scriptdir/tmp"
mkdir -p "$trovedir"
mkdir -p "$tmpdir"

rm -f "$tmpdir"/*.json

list_id="kindle"

output_file="$trovedir/$list_id.json"

perl "$scriptdir/convert.pl" $list_id Kindle Kindle "$scriptdir/$list_id.txt" > "$output_file"
