#!/usr/bin/env bash
set -o errexit # set -e
set -o pipefail
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
script_file=$(basename "$0")

imagesdir="$1"
echo "IMAGES DIR $imagesdir" 1>&2

source "$script_dir/../../shared/functions.sh"

is_installed aws
is_installed magick

set -o nounset # set -u

tmp_dir=${DG_TMP:-./tmp}
mkdir -p "$tmp_dir"

srcdir="$tmp_dir"
destdir="$tmp_dir"
bucket="little-prince"

set +e
aws s3 ls
if [[ "$?" != "0" ]]; then
  echo "You must have the aws CLI installed, and you must login to AWS or supply AWS env vars (see the envrc_template file)"
  exit 1
fi
set -e

json_file="$destdir/uploaded-covers.json"
cp /dev/null "$json_file"

mkdir -p "$destdir"/1500
mkdir -p "$destdir"/150

for filename in $imagesdir/*; do

  ## Rename to canonical, and create thumbnail

  base_filename=$(basename "$filename")
  canon_filename="${base_filename// /-}"
  canon_filename="${base_filename//+/plus}"
  echo CANONICAL FILENAME $canon_filename

  title="$base_filename"
  title="$(basename "$title" .jpeg)"
  title="$(basename "$title" .jpg)"
  title="$(basename "$title" .png)"
  title="$(basename "$title" .gif)"
  title="$(basename "$title" .webp)"

  if [[ "$base_filename" == "$title" ]]; then
    echo "... covers upload: SKIP NON-IMAGE FILE: $filename" 1>&2
    continue
  fi

  echo ... covers upload IMAGE FILE: $filename 1>&2
  echo ... covers upload RAW TITLE: $title 1>&2

  export IFS=$'\n'
  title_language=($("$script_dir/title-language.pl" "$title"))
  unset IFS

  echo covers upload: TITLE LANGUAGE "${title_language[@]}" 1>&2

  title="${title_language[0]}"
  language="${title_language[1]}"

  title=$(echo "$title" | tr -d '"')
  language=$(echo "$language" | tr -d '"')

  echo ... covers upload: PROCESSED TITLE $title 1>&2
  echo ... covers upload: LANGUAGE $language 1>&2

  f1500="$destdir/1500/$canon_filename"
  f150="$destdir/150/$canon_filename"

  cp "$filename" "$f1500"

  os='other'
  if [[ "$os" == "macos" ]]; then
    magick convert "$f1500" -thumbnail 200x200 "$f150"
  else
    convert "$f1500" -thumbnail 200x200 "$f150"
  fi
  ## Upload to AWS
  set -x
  aws s3 cp "$f1500" "s3://moocho-test/public/$bucket/images/1500/$canon_filename"
  aws s3api put-object-acl --bucket moocho-test --key "public/$bucket/images/1500/$canon_filename" --grant-full-control emailaddress=carl@dragnon.com --grant-read uri=http://acs.amazonaws.com/groups/global/AllUsers

  aws s3 cp "$f150" "s3://moocho-test/public/$bucket/images/150/$canon_filename"
  aws s3api put-object-acl --bucket moocho-test --key "public/$bucket/images/150/$canon_filename" --grant-full-control emailaddress=carl@dragnon.com --grant-read uri=http://acs.amazonaws.com/groups/global/AllUsers
  set +x
  ## Output JSON snippet

  cat >>"$json_file" <<EOF
    {
      "littlePrinceItem": {
        "title": "$title",
        "largeImageUrl": "https://moocho-test.s3-us-west-2.amazonaws.com/public/$bucket/images/1500/$canon_filename",
        "language": "$language",
        "smallImageUrl": "https://moocho-test.s3-us-west-2.amazonaws.com/public/$bucket/images/150/$canon_filename"
      }
    },
EOF

  echo "... covers upload: Output file: $json_file" 1>&2

done
