#!/usr/bin/env bash
set -o errexit # set -e
set -o pipefail
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
script_file=$(basename "$0")

dir=$1

if [[ "$dir" == "" ]]; then
  cat <<EOF
USAGE: $script_file [dir with filenames containing PP-*]
EOF
  exit 1
fi

ppids=$(ls "${dir}" | grep -Eo 'PP-\d+' | sort | uniq)
dg $(echo $ppids)
