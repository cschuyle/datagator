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

python3 "$script_dir/netflixhtml2json.py" athomeList "$saved_html_file" >netflix-athome.json
python3 "$script_dir/netflixhtml2json.py" inqueueList "$saved_html_file" >netflix-queue.json
python3 "$script_dir/netflixhtml2json.py" savedList "$saved_html_file" >netflix-saved.json

"${script_dir}"/netflixjson2csv.sh netflix-athome.json >netflix-athome.csv
"${script_dir}"/netflixjson2csv.sh netflix-queue.json >netflix-queue.csv
"${script_dir}"/netflixjson2csv.sh netflix-saved.json >netflix-saved.csv

"${script_dir}"/netflixjson2txt.sh netflix-athome.json >netflix-athome.txt
"${script_dir}"/netflixjson2txt.sh netflix-queue.json >netflix-queue.txt
"${script_dir}"/netflixjson2txt.sh netflix-saved.json >netflix-saved.txt
