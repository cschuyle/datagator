jq -r '.[] | "\(.title) (\(.year))"' $1 \
  | sed 's/ (null)//'
