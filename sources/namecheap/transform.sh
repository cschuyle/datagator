#!/usr/bin/env bash
set -o errexit # set -e
set -o nounset # set -u
set -o pipefail
set -o xtrace # set -x
## Boilerplate
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" # where does this script live
rootdir="$scriptdir/../.." # repo root
source "$rootdir/shared/functions.sh" # shared functions

trovedir="$scriptdir/output"
tmpdir="$scriptdir/tmp"
mkdir -p "$trovedir"
mkdir -p "$tmpdir"

transform-and-stage() {

    set -e

    input_file=$1
    name=$2
    short_name=$3

    output_file="$trovedir/$(basename "$input_file" .txt).json"
    trove_id=$(basename "$output_file" .json)

    lines2json "$input_file" "$trove_id" "$name" "$short_name" "$output_file"
}

mkdir -p "$trovedir"

transform-and-stage "$scriptdir/namecheap.txt" "Namecheap" "Namecheap"
