#!/usr/bin/env bash
set -o errexit # set -e
set -o pipefail
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
script_file=$(basename "$0")

source "$script_dir/../../shared/functions.sh"

detect_host_and_sourcedir

# Only implemented thing so far: video "search"

search="$1"
video_root="$mydatadir/Noncloud-Data/video"
cd "$video_root"
ls -d */*|grep -i "$search"
