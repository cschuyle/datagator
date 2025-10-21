#!/usr/bin/env bash
set -o errexit # set -e
set -o nounset # set -u
set -o pipefail
## Boilerplate
scriptdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # where does this script live
rootdir="$scriptdir/../.."                                # repo root
#source "$rootdir/ci/bin/functions.sh"                     # shared functions

function a-little {
    min=0
    max=3
    number=$(expr $min + $RANDOM % $max)
    echo $number
}


cd "$scriptdir"

curl -s https://petit-prince-collection.com/lang/collection.php?lang=en > collection-LANGUAGES.html
echo @@@@@@@@@ Extract languages from collection-LANGUAGES.html
./extract-languages.pl collection-LANGUAGES.html | sort -n > collection-LANGUAGES.txt

# echo @@@@@@@@@ Download main doubles / trade / sell page
# sleep `a-little`
# curl -s 'https://petit-prince-collection.com/lang/doubles.php?lang=en&doubles=69' > main-doubles.html

# TODO This list of links should come from main-doubles.html
for doublescat in 69 58 59 31 149; do
# The above cats are : spanish chinese korean english russian
    echo @@@@@@@@@ Download doubles-$doublescat.html
    curl -s 'https://petit-prince-collection.com/lang/doubles.php?lang=en&doubles='$doublescat > "doubles-$doublescat.html"
    sleep `a-little`
done

echo @@@@@@@@@ Download Other Doubles
curl -s 'https://petit-prince-collection.com/lang/doubles_autres.php?lang=en' > doubles-OTHER.html
sleep `a-little`

echo @@@@@@@@@ Download special-books.html
curl -s 'https://petit-prince-collection.com/lang/doubles_SP.php?lang=en' > special-books.html
sleep `a-little`

for year in $(seq 2012 2025); do
    echo @@@@@@@@@ Download new-$year.html
    curl -s "https://petit-prince-collection.com/lang/nouveautes.php?lang=en&nouv=$year" > "new-$year.html"
    sleep `a-little`
done

echo @@@@@@@@@ Download Unique Items
curl -s 'https://petit-prince-collection.com/lang/objets_uniques.php?lang=en' > 'object-uniques.html'
sleep `a-little`

echo @@@@@@@@@ Download In Progress
curl -s 'https://petit-prince-collection.com/lang/fon_cur_act.php?lang=en' > 'in-progress.html'

# Done curling

for file in doubles-*.html new-*.html
do
    echo @@@@@@@@@ Extract LPIDs from $file
    ./extract-lpids.pl "$file" | sort > "lpids-$(basename "$file" .html).txt"
done
