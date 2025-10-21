#!/usr/bin/env bash
set -o errexit # set -e
set -o nounset # set -u
set -o pipefail
## Boilerplate
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" # where does this script live
rootdir="$scriptdir/../.." # repo root
source "$rootdir/ci/bin/functions.sh" # shared functions

cd "$scriptdir"
./parse.pl dvdinbox.txt > dvdinbox.tsv
