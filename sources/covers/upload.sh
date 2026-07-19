#!/usr/bin/env bash
set -o errexit # set -e
set -o pipefail
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
script_file=$(basename "$0")

source "$script_dir/../../shared/functions.sh"

is_installed aws
is_installed magick
is_installed Text::Autoformat

force=0
imagesdir=""
for arg in "$@"; do
  case "$arg" in
    -f|--force) force=1 ;;
    *) imagesdir="$arg" ;;
  esac
done

if [[ -z "$imagesdir" ]]; then
  echo "USAGE: $script_file [-f|--force] [DIRECTORY OF IMAGES]" 1>&2
  exit 1
fi

echo "@@@@@ Scanning for cover images: $imagesdir" 1>&2
if [[ "$force" -eq 1 ]]; then
  echo "@@@@@ Force mode: will upload images even if they already exist" 1>&2
fi

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

uploaded_count=0

for filename in $imagesdir/*; do

  ## Rename to canonical, and create thumbnail

  base_filename=$(basename "$filename")
  canon_filename="${base_filename// /-}"
  canon_filename="${canon_filename//+/plus}"

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
  large_key="public/$bucket/images/1500/$canon_filename"
  if [[ "$force" -eq 0 ]] && aws s3api head-object --bucket moocho-test --key "$large_key" >/dev/null 2>&1; then
    echo "@@@ WARNING: large image already exists, skipping upload (use -f to force) [$large_key]" 1>&2
  else
    echo "@@@ Uploading large image [$canon_filename] to AWS" 1>&2
    aws s3 cp "$f1500" "s3://moocho-test/$large_key" >/dev/null
    if ! aws s3api put-object-acl \
      --bucket moocho-test \
      --key "$large_key" \
      --grant-full-control emailaddress=carl@dragnon.com \
      --grant-read uri=http://acs.amazonaws.com/groups/global/AllUsers >/dev/null 2>&1; then
      echo "@@@ WARNING: Failed to set public ACL on s3://moocho-test/$large_key (object uploaded; bucket policy may still allow public read)" 1>&2
    fi
    uploaded_count=$((uploaded_count + 1))
  fi

  small_key="public/$bucket/images/150/$canon_filename"
  if [[ "$force" -eq 0 ]] && aws s3api head-object --bucket moocho-test --key "$small_key" >/dev/null 2>&1; then
    echo "@@@ WARNING: small image already exists, skipping upload (use -f to force) [$small_key]" 1>&2
  else
    echo "@@@ Uploading small image [$canon_filename] to AWS" 1>&2
    aws s3 cp "$f150" "s3://moocho-test/$small_key" >/dev/null
    if ! aws s3api put-object-acl \
      --bucket moocho-test \
      --key "$small_key" \
      --grant-full-control emailaddress=carl@dragnon.com \
      --grant-read uri=http://acs.amazonaws.com/groups/global/AllUsers >/dev/null 2>&1; then
      echo "@@@ WARNING: Failed to set public ACL on s3://moocho-test/$small_key (object uploaded; bucket policy may still allow public read)" 1>&2
    fi
    uploaded_count=$((uploaded_count + 1))
  fi
  # set +x

  ## Output JSON snippet

  lpid="$("${script_dir}/extract-lpid.pl" "${canon_filename}")"
  tintenfass_id="$("${script_dir}/extract-tintenfass-id.pl" "${canon_filename}")"
  if [[ -n "$tintenfass_id" ]]; then
    tintenfass_line="          \"tintenfassId\": \"$tintenfass_id\","
  else
    tintenfass_line=""
  fi
  extra_metadata_file="${imagesdir}/$lpid.json"
  # echo CHECK FOR $extra_metadata_file
  if [[ -f "$extra_metadata_file" ]]; then
    echo "@@@ FOUND EXTRA METADATA file for $title - $language: [$extra_metadata_file]" 1>&2
    cat "$extra_metadata_file" 1>&2
    echo "---" 1>&2

    # Merge the native title from the metadata (e.g. "El Prencipicu") with the
    # descriptive filename title, so a single "title" carries both.
    metadata_title=$(perl -ne '/"title"\s*:\s*"(.*)"/ and print $1' "$extra_metadata_file")
    if [[ -n "$metadata_title" ]]; then
      combined_title="$metadata_title - $title"
    else
      combined_title="$title"
    fi

    # Fold language2 into language: same -> keep one value; different -> comma-join.
    # Never emit a separate language2 field.
    language2=$(perl -ne '/"language2"\s*:\s*"(.*)"/ and print $1' "$extra_metadata_file")
    if [[ -n "$language2" && "$language2" != "$language" ]]; then
      combined_language="$language, $language2"
      echo "@@@ Combining language [$language] and language2 [$language2]" 1>&2
    else
      combined_language="$language"
      if [[ -n "$language2" ]]; then
        echo "@@@ Omitting language2 (duplicate of language [$language])" 1>&2
      fi
    fi

    cat >>"$json_file" <<EOF
      {
        "littlePrinceItem": {
          "title": "$combined_title",
          "largeImageUrl": "https://moocho-test.s3-us-west-2.amazonaws.com/public/$bucket/images/1500/$canon_filename",
          "language": "$combined_language",
$tintenfass_line
          "smallImageUrl": "https://moocho-test.s3-us-west-2.amazonaws.com/public/$bucket/images/150/$canon_filename",
EOF

  # Drop metadata title (folded above) and language2 (folded into language).
  # Re-indent appended metadata to 10 spaces so it lines up with the sibling fields.
  grep -Ev '"title"|"language2"' "$extra_metadata_file" | sed -E 's/^[[:space:]]*/          /' >> "$json_file"

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
$tintenfass_line
          "smallImageUrl": "https://moocho-test.s3-us-west-2.amazonaws.com/public/$bucket/images/150/$canon_filename"
        }
      },
EOF

  fi

done

if [[ "$uploaded_count" -eq 0 ]]; then
  echo "@@@@@ WARNING: No images were uploaded." 1>&2
fi

# Left/right trim whitespace inside every "key": "value" pair in the output JSON
perl -i -pe 's/:[ \t]*"[ \t]*(.*?)[ \t]*"[ \t]*(,?)[ \t]*$/: "$1"$2/' "$json_file"

echo "@@@@@ Output file [$json_file]. Copied to clipboard." 1>&2
{ echo ":>>>>> From dg covers"; cat "$json_file"; } | pbcopy
