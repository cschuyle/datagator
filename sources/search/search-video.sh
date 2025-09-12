#!/usr/bin/env bash
set -o errexit # set -e
set -o pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
script_file=$(basename "$0")

source "$script_dir/../../shared/functions.sh"

detect_host_and_sourcedir

# How many formats do we have? Let us count the ways ....

do-search-on-dir-names-from-video() {
	dir="$1"
	cd "$dir"
	ls -d */*|grep -i "$search" || true
}

do-search-on-file-contents() {
	file="$1"
	cd "$(dirname "$file")"
	grep -i "$search" "$(basename "$file")" || true
}

do-search-on-titles() {
	file="$1"
	cat "$file" | jq -r '.titles[]' | grep -i "$search" || true
}

do-search-on-lp-item() {
	file="$1"
    cat "$file" | jq -r '.items[].littlePrinceItem.title' | grep -i "$search" || true

}

search="$1"

echo "@@ video"
video_root="$mydatadir/Noncloud-Data/video"
do-search-on-dir-names-from-video "$video_root"

echo "@@ Namecheap"
moocho_root="$HOME/Yew/moocho"
namecheap_file="$moocho_root/troves/namecheap/namecheap.txt"
do-search-on-file-contents "$namecheap_file"

echo "@@ eBooks" 
ebooks_file="$moocho_root/troves/synology-ebooks/ebooks.json"
do-search-on-titles "$ebooks_file"

echo "@@ Books"
books_file=""$moocho_root/troves/books/books.json"
do-search-on-lp-item "$books_file"
