echo title,year,rating,duration,series,disc
jq -r '.[] | "\(.title),\(.year),\(.rating),\(.duration),\(.series),\(.disc)"' $1
