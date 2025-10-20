#!/usr/bin/env bash
set -o errexit # set -e
set -o nounset # set -u
set -o pipefail
## Boilerplate
scriptdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # where does this script live
rootdir="$scriptdir/../.."                                # repo root
source "$rootdir/shared/functions.sh"                     # shared functions

is_installed csvformat

trovedir="$scriptdir/output"
tmpdir="$scriptdir/tmp"
mkdir -p "$trovedir"
mkdir -p "$tmpdir"

tsv_header="Date Added	Image URL	Title	Author	ASIN	Price	Item URL	List Name"
csv_header="Date Added,Image URL,Title,Author,ASIN,Price,Item URL,List Name"

lists_dir="$scriptdir/lists"
cd "$lists_dir"

declare -a files
files=(*)

echo @@@@ There are ${#files[@]} files to process.

cd "$tmpdir"

# `for x in ...`` doesn't work when there are spaces in the items.
# for tsv_file in ${files[@]}; do    
for (( i = 0; i < ${#files[@]}; i++ )); do
  tsv_file="${files[$i]}"

  echo @@@@ File: $tsv_file

  if [[ ! "$(echo "$tsv_file" | grep -e '.tsv$')" ]]; then
    echo ERROR: $tsv_file doesn't end in .tsv. Why not\?
    exit 1
  fi

  if [[ "$tsv_header" != "$(head -1 "$lists_dir/$tsv_file")" ]]; then
    echo ERROR: Headers don't match for $lists_dir/$tsv_file
    exit 1
  fi
  
  list_name=$(basename "$tsv_file" ".tsv")
  echo @@@@ List: $list_name

  list_id="$list_name"
  echo @@@@ List ID: $list_id
 
  list_short_name="$list_name"
  echo @@@@ List short name: $list_short_name

  csv_file="amazon-${list_id}.csv"
  \rm -f "$csv_file"
  tail -n+2 "$lists_dir/$tsv_file" | csvformat -t -Q '"' -U 1 >"$csv_file"


  catted_csv_file="amazon-${list_id}-catted.csv"
  \rm -f "$catted_csv_file"

  tail -n+2 "$lists_dir/$tsv_file" | csvformat -t -Q '"' -U 1 > "$catted_csv_file"

  sorted_csv_file="amazon-${list_id}-catted-sorted.csv"
  echo ... $sorted_csv_file - Sort and uniq, stick a header at the top
  \rm -f "$sorted_csv_file"

  echo "$csv_header" | cat > "$sorted_csv_file"
  cat "$catted_csv_file" | sort | uniq >> "$sorted_csv_file"

  tmp_json_file="amazon-${list_id}-jsonified.json"
  echo ... $tmp_json_file is just the CSV, JSONified
  \rm -f "$tmp_json_file"

  csvjson "$sorted_csv_file" | cat >"$tmp_json_file.with-nulls"
  cat "$tmp_json_file.with-nulls" | jq '[ .[] | select(."List Name" | . != null) ]' | cat >"$tmp_json_file"

  json_file="$trovedir/amazon-$list_id.json"
  echo @@@@ Output JSON file: $json_file
  \rm -f "$json_file"

  cat "$tmp_json_file" | jq "
  {
    id: \"amazon-${list_id}\",
    name: \"Amazon: ${list_name}\",
    shortName: \"Amazon-${list_short_name}\",
    items: [
    .[] |
    {
        littlePrinceItem: {
          amazonList: .\"List Name\",
          title: (.Title // \"\"),
          author: (.Author // \"\"),
          dateAdded: .\"Date Added\",
          itemUrl: (.\"Item URL\" // \"\"),
          smallImageUrl: (.\"Image URL\" // \"\"),
          asin: (.ASIN // \"\"),
          price: (.Price // 0),
          language: \"\",
          largeImageUrl: \"\"
        }
      }
    ]
  }" > "$json_file"

  echo "@@@ $json_file - Output file:
  $(ls -l "$json_file")
  " 1>&2

done
