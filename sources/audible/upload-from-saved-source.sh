#!/usr/bin/env bash
set -o errexit # set -e
set -o nounset # set -u
set -o pipefail
set -o xtrace # set -x
## Boilerplate
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" # where does this script live
rootdir="$scriptdir/../.." # repo root
source "$rootdir/ci/bin/functions.sh" # shared functions

is_installed xmlstarlet

if [[ ! $(command -v pup) ]]; then
    cat <<EOF
    Must have pup. Try:
brew install pup
EOF
    exit 1
fi

srcFile="$HOME/Downloads/My Library | Audible.com.html"

if [[ ! -f "$srcFile" ]]; then
    echo "$srcFile does not exist"
    exit 1
fi
rm -f "$scriptdir/My Library | Audible.com.html"
cp "$srcFile" "$scriptdir"

rm -f "$scriptdir/audible.txt" 
cat "$scriptdir/My Library | Audible.com.html" | \
    pup '#adbl-library-content-main  .bc-list-item .bc-link .bc-size-headline3:nth-child(1) text{}' | \
    xmlstarlet unesc | \
    perl -ne 's/^\s*//; s/\s*$//; print "$_\n" unless /^\s*$/;' > \
    "$scriptdir/audible.txt"
    
