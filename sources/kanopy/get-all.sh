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

# Use Reelgood API to get all Kanopy movies
# Worked on MacOS Monterey 12.6.3 as of Mar 12, 2023
#
# Usage: ./get-kanopy-from-reelgood.sh
# Outputs 2 files: kanopy.json and kanopy.txt

cmdExists() {
    cmdName=$1
    cmdLoc="$(type -p "$cmdName")" || [ -z $cmdLoc ]
    echo $cmdLoc
}
trim() { echo "$@"|xargs; }
dots() {
    local page=$1
    local pageSize=$2
    local mod=$3
    if [ $page -ne 0 ]
    then
        if [ $(expr $page \* $pageSize % $mod) -eq 0 ]
        then
            echoerr "$(expr $page \* $pageSize)\n"
        else
            echoerr "."
        fi
    fi
}

if [ ! "$(cmdExists 'jq')" ]
then
    echoerr You gotta install jq
    exit 1
fi

cd "$(mktemp -d)"
(
    page=0
    pageSize=100 # 100 max

    # while [ $page -lt 3 ] # test
    while true
    do
        skip=$(expr $page \* $pageSize) || true

        dots $page $pageSize 1000
        curl -s https://api.reelgood.com/v3.0/content/browse/source/kanopy\?availability\=onSources\&content_kind\=movie\&hide_seen\=false\&hide_tracked\=false\&hide_watchlisted\=false\&imdb_end\=10\&imdb_start\=0\&override_user_sources\=true\&overriding_free\=false\&overriding_sources\=kanopy\&region\=us\&rg_end\=100\&rg_start\=0\&sort\=0\&sources\=kanopy\&take\=$pageSize\&year_end\=2023\&year_start\=1900\&skip\=$skip | \
            jq -r .results \
            > "$page.json"

        lines=$(wc -l < "$page.json") # < is a neato way to prevent wc from outputting a file name
        [ $lines -lt 10 ] && break
        sleep $(expr $RANDOM % 2)
        page=$(expr $page + 1)
    done

    echoerr "
Done reading from Realgood API.
    Writing $tmpdir/kanopy.json ...
"

    jq -n '{ list: [ inputs ] | add }' $(echo *.json) > "$tmpdir/kanopy.json"
)

echoerr "    Sorting by title and writing $trovedir/kanopy.txt ...
"
cat "$tmpdir/kanopy.json" | jq -r '.list[].title' | sort > "$trovedir/kanopy.txt"
echoerr "Done. Reelgood has $(trim $(wc -l < "$trovedir/kanopy.txt")) Kanopy movies.
"