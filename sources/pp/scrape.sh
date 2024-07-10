#!/usr/bin/env bash
set -o errexit # set -e
set -o pipefail
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
script_file=$(basename "$0")

lpid=$1

if [[ "$lpid" == "" ]]; then
  cat <<EOF
USAGE: $script_file [Jean Marc Little Prince Collection ID]
EOF
  exit 1
fi

tmp_dir=${DG_TMP:-./tmp}
mkdir -p "$tmp_dir"

echo "... cd \"$tmp_dir\"" 1>&2
cd "$tmp_dir"

url="https://www.petit-prince-collection.com/lang"

echo "... curl -s $url/show_livre.php\?lang\=en\&id\=$lpid > \"$lpid.html\"" 1>&2
curl -s $url/show_livre.php\?lang\=en\&id\=$lpid > $lpid.html

val=$(
    cat "$lpid.html" | \
    grep -B 2 -A 2 '<div class="feature">' | \
    tail -1 | \
    perl -pe 's/.*&nbsp;//' | \
    perl -pe 's/<.?[^>+]+>//g' | \
    perl -pe 's/^\s*//' | \
    perl -pe 's/\s*$//'
    ) && if [[ ! -z "$val" ]]; then echo "  \"language\": \"$val\"," >> "PP-$lpid.json"; language=$val; fi

val=$(
    cat "$lpid.html" | \
    grep '<title>' | perl -ne '/\/(.+)\/.*?\d{4}/ and print $1 or die "HORRIBLY";' | perl -pe 's/&nbsp;//g;'
    ) && if [[ ! -z "$val" ]]; then echo "  \"language\": \"$val\"," >> "PP-$lpid.json"; language=$val; fi


val=$(cat $lpid.html|grep -B 2 -A 2 '>Translator(s):<'|tail -1|perl -pe 's/<[^>+]+>//g' | perl -pe 's/^\s*//' | perl -pe 's/\s*$//') && echo "  \"translator\": \"$val\"," >> "PP-$lpid.json"
val=$(cat $lpid.html|grep -B 2 -A 2 '>Year of publication:<'|tail -1|perl -pe 's/<[^>+]+>//g' | perl -pe 's/^\s*//' | perl -pe 's/\s*$//') && echo "  \"year\": \"$val\"," >> "PP-$lpid.json"
val=$(cat $lpid.html|grep -B 2 -A 2 '>Place of publication:<'|tail -1|perl -pe 's/<[^>+]+>//g' | perl -pe 's/^\s*//' | perl -pe 's/\s*$//') && echo "  \"publication-location\": \"$val\"," >> "PP-$lpid.json"
val=$(cat $lpid.html|grep -B 2 -A 1 '>ISBN:<'|tail -1|perl -pe 's/<[^>+]+>//g' | perl -pe 's/^\s*//' | perl -pe 's/\s*$//') && echo "  \"isbn13\": \"$val\"," >> "PP-$lpid.json"
val=$(cat $lpid.html|grep -B 2 -A 1 '>Publisher:<'|tail -1|perl -pe 's/<[^>+]+>//g' | perl -pe 's/^\s*//' | perl -pe 's/\s*$//') && echo "  \"publisher\": \"$val\"," >> "PP-$lpid.json"
val=$(cat $lpid.html|grep -B 2 -A 2 '>Illustrations:<'|tail -1|perl -pe 's/<[^>+]+>//g' | perl -pe 's/^\s*//' | perl -pe 's/\s*$//') && echo "  \"illustrator\": \"$val\"," >> "PP-$lpid.json"
echo "  \"lpid\": \"PP-$lpid\"" >> "PP-$lpid.json"

cover=$(cat $lpid.html|perl -ne '/href="(.+_XXL[^"]+)"/ && print "$1\n";' | head -1) 

echo COVERS $cover 1>&2

cover_url="$url/$cover"
extension="${cover_url##*.}"

echo "... wget -q \"$cover_url\" -O \"little prince - $language PP-$lpid.$extension\"" 1>&2

wget -q "$cover_url" -O "little prince - $language PP-$lpid.$extension"

echo "... touch \"little prince - $language PP-$lpid.$extension\"" 1>&2
touch "little prince - $language PP-$lpid.$extension"

