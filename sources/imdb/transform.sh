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

declare -a list_ids
readarray -t list_ids < "$scriptdir/sub-troves.txt"

declare -A lists

name() {
    echo ${lists[$1,name]}
}

short_name() {
    echo ${lists[$1,short_name]}
}

file() {
    echo ${lists["$1,file"]}
}

list() {
    lists["$1,name"]="$2"
    lists["$1,short_name"]="$3"
    lists["$1,file"]="$4"
}

# NOTE: This list must be in sync with ./sub-troves.txt
#    id             name                                    short-name          file         
list 'watchlist'    "IMDB: Watchlist"                       "IMDB Watchlist"    'WATCHLIST.csv'

mkdir -p "$trovedir"

lists_dir="${scriptdir}/lists"

for list in ${list_ids[@]}; do    
    file="${lists_dir}/$(file $list)"
    [[ ! -f "$file" ]] && echo "ERROR: File not found: $file" && exit 1
    
    output_file="$tmpdir/imdb-$list.json"
    name="$(name $list)"
    short_name="$(short_name $list)"
    lines="${tmpdir}/imdb-$list.txt"
    json="${tmpdir}/imdb-$list.items.json"

    echo @@@@ IMDB list $short_name
    
    csvjson "$file" \
        | jq '.[] | "\(.Title) (\(.Year))"' \
        | sed "s/^\"//" \
        | sed "s/\"\$//" \
        | sed "s/\.0)/)/" \
        > "$lines"

    csvjson "$file" \
        | jq '{items: [ .[] | {imdbitem: {title: .Title, titletype: ."Title Type", originaltitle: ."Original Title", year: .Year|tostring, imdburl: .URL, rating: ."IMDb Rating", runtime: ."Runtime (mins)"}} ]}' \
        | sed -r 's/\.0//' \
       > "$json"

    lines2json "$lines" "$list" "$name" "$short_name" "$output_file"
    
    mv "$output_file" "$trovedir/"
done
