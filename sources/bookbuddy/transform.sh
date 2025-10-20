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

is_installed csvjson

cd "$tmpdir"

csvjson "$scriptdir/BookBuddy.csv" \
  | jq . > "bookbuddy.json"

cat \
    "$scriptdir/head.json-fragment" \
    <( csvjson "$scriptdir/BookBuddy.csv" | jq ) \
    "$scriptdir/tail.json-fragment" \
  > bookbuddy.json

mv "bookbuddy.json" "$trovedir/"


