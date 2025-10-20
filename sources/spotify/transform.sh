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

checkcommands() {

for i in "$@";do
    if ! command -v "$i" &>/dev/null ;then
        echo "Command \"$i\" not found. Please install \"$i\"."
        exit 1
    fi
done

}

checkcommands perl csvjson

mkdir -p "$trovedir"
rm -f "$tmpdir"/*.csv
rm -f "$tmpdir"/*.json

for export in "$scriptdir"/exports/*.csv ; do
    basename=$(basename "$export" .csv)
    listname="${basename//_/ }"
    cp "$export" "$tmpdir/$basename".csv
    export="$tmpdir/$basename".csv

    # Get rid of BOM bytes at beginning of exported files
    dos2unix "$export"
    perl -pi~ -e 's/\x{ef}\x{bb}\x{bf}//' "$export"

    if [[ "$(uname)" == "Darwin" ]]; then
        SED=gsed
    else
        SED=sed
    fi

    checkcommands $SED

    # Bug? in csvjson.  It won't extract the first field.  So we'll prepend a field to CSV.
    $SED -i 's/^/42,/' "$export"

    # For some reason on mac the feff a.k.a. ef bb bf, a.k.a. BOM Byte Order Marker gets resurrected
    perl -pi~ -e 's/\x{ef}\x{bb}\x{bf}//' "$export"

    # Songs with double quotes in them result in unquoted double quotes.
    perl -pi -e 's/([^,])"([^,])/$1""$2/g' "$export"
    perl -pi -e 's/""$/"/' "$export"

    perl -pi -e 's/","/qqccqq/g' "$export"
    perl -pi -e 's/^"/caretqq/' "$export"
    perl -pi -e 's/"$/qqdollar/g' "$export"
    perl -pi -e 's/"/""/g' "$export"
    perl -pi -e 's/qqccqq/","/g' "$export"
    perl -pi -e 's/^caretqq/"/' "$export"
    perl -pi -e 's/qqdollar$/"/' "$export"

    outfile="$tmpdir/$basename.json"

    # csvjson
    csvjson "$export" | \
        jq  ".[] | {
            spotifyItem: {
                title: .\"Track Name\",
                addedAt: .\"Added At\",
                trackName: .\"Track Name\",
                trackUri: .\"Track URI\",
                albumName: .\"Album Name\",
                albumUri: .\"Album URI\",
                artistName: .\"Artist Name(s)\",
                artistUri: .\"Artist URI(s)\",
                albumArtistName: .\"Album Artist Name(s)\",
                albumArtistUri: .\"Album Artist URI(s)\",
                trackDurationMs: .\"Track Duration (ms)\",
                trackPreviewUrl: .\"Track Preview URL\",
                albumReleaseDate: .\"Album Release Date\",
                albumImageUrl: .\"Album Image URL\",
                playlistName: \"$listname\"
            }
        }" \
        > "$outfile"
done

cat "$tmpdir"/*.json \
    | jq --slurp '.' \
    > "$tmpdir/spotify.objects"

cat "$tmpdir/spotify.objects" \
    | jq '{ items: [.[]]}' \
    | jq '. + {id: "spotify", name: "Spotify Playlists", "shortName": "Spotify"}' \
    > "$trovedir/spotify.json"
