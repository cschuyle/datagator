#!/usr/bin/env bash
set -o errexit # set -e
set -o pipefail
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
script_file=$(basename "$0")

source "$script_dir/../shared/functions.sh"

saved_html_file=${1:-"$(pwd)/DVD Netflix.html"}

if [[ ! -f $saved_html_file ]]; then
  echo "File not found: $saved_html_file. Go to your Netflix queue page in your browser, and save the web page to disk."
  exit 1
fi

python3 "$script_dir/netflixhtml2txt.py" athomeList "$saved_html_file" >netflix-athome.txt
python3 "$script_dir/netflixhtml2txt.py" inqueueList "$saved_html_file" >netflix-queue.txt
python3 "$script_dir/netflixhtml2txt.py" savedList "$saved_html_file" >netflix-saved.txt
