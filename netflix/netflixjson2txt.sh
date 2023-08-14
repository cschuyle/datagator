jq -r '.[] | "\(.title) (\(.year)) (Season \(.season), Disc \(.disc))"' $1 \
  | sed 's/ (null)//' \
  | sed 's/ (Season null, Disc null)//' \
  | sed 's/Season Season/Season/' \
  | sed 's/Disc Disc/Disc/' \
  | sed 's/Season null, //' \
