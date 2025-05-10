#!/usr/bin/env bash
set -o errexit # set -e
set -o pipefail
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
script_file=$(basename "$0")

source "$script_dir/../../shared/functions.sh"

is_installed aws
is_installed magick
is_installed Text::Autoformat

imagesdir="$1"
echo "@@@@@ Scanning for cover images: $imagesdir" 1>&2

set -o nounset # set -u

tmp_dir=${DG_TMP:-./tmp}
mkdir -p "$tmp_dir"

srcdir="$tmp_dir"
destdir="$tmp_dir"
bucket="little-prince"

set +e
aws sts get-caller-identity 1>&/dev/null
if [[ "$?" != "0" ]]; then
  echo "Error: You must have the aws CLI installed, and you must login to AWS or supply AWS env vars (see the envrc_template file)"
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

  title="$base_filename"
  title="$(basename "$title" .jpeg)"
  title="$(basename "$title" .jpg)"
  title="$(basename "$title" .png)"
  title="$(basename "$title" .gif)"
  title="$(basename "$title" .webp)"

  if [[ "$base_filename" == "$title" ]]; then
    echo "@@@@ Skip non-image file [$filename]" 1>&2
    continue
  fi

  echo "@@@@ Processing file [$filename]" 1>&2

  export IFS=$'\n'
  title_language=($("$script_dir/title-language.pl" "$title"))
  unset IFS

  title="${title_language[0]}"
  language="${title_language[1]}"

  title=$(echo "$title" | tr -d '"')
  language=$(echo "$language" | tr -d '"')

  echo "@@@ Title: $title" 1>&2
  echo "@@@ Language: $language" 1>&2

  f1500="$destdir/1500/$canon_filename"
  f150="$destdir/150/$canon_filename"

  cp "$filename" "$f1500"

  # os='other'
  # if [[ "$os" == "macos" ]]; then
    magick "$f1500" -thumbnail 200x200 "$f150"
  # else
  #   convert "$f1500" -thumbnail 200x200 "$f150"
  # fi

  ## Upload to AWS
  # set -x
  echo "@@@ Uploading large image [$canon_filename] to AWS" 1>&2
  aws s3 cp "$f1500" "s3://moocho-test/public/$bucket/images/1500/$canon_filename" >/dev/null

  echo "@@@ Setting public access to large image" 1>&2
  aws s3api put-object-acl --bucket moocho-test --key "public/$bucket/images/1500/$canon_filename" --grant-full-control emailaddress=carl@dragnon.com --grant-read uri=http://acs.amazonaws.com/groups/global/AllUsers


  echo "@@@ Uploading small image [$canon_filename] to AWS" 1>&2
  aws s3 cp "$f150" "s3://moocho-test/public/$bucket/images/150/$canon_filename" >/dev/null
  
  echo "@@@ Setting public access to small image" 1>&2
  aws s3api put-object-acl --bucket moocho-test --key "public/$bucket/images/150/$canon_filename" --grant-full-control emailaddress=carl@dragnon.com --grant-read uri=http://acs.amazonaws.com/groups/global/AllUsers
  # set +x

  ## Output JSON snippet

  lpid="$("${script_dir}/extract-lpid.pl" "${canon_filename}")"
  extra_metadata_file="${imagesdir}/$lpid.json"
  # echo CHECK FOR $extra_metadata_file
  if [[ -f "$extra_metadata_file" ]]; then
    echo "@@@ FOUND EXTRA METADATA file for $title - $language: [$extra_metadata_file]" 1>&2
    cat "$extra_metadata_file" 1>&2
    echo "---" 1>&2

    cat >>"$json_file" <<EOF
      {
        "littlePrinceItem": {
          "title": "$title",
          "largeImageUrl": "https://moocho-test.s3-us-west-2.amazonaws.com/public/$bucket/images/1500/$canon_filename",
          "language": "$language",
          "smallImageUrl": "https://moocho-test.s3-us-west-2.amazonaws.com/public/$bucket/images/150/$canon_filename",
EOF

  cat "$extra_metadata_file" >> "$json_file"

  cat >>"$json_file" <<EOF
        }
      },
EOF
  
  else
      echo "@@@ NO EXTRA METADATA for $title - $language" 1>&2

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

  fi

done

echo "@@@@@ Output file [$json_file]. Copied to clipboard." 1>&2
cat "$json_file" |pbcopy
