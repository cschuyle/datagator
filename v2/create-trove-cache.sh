mkdir -p trove-cache
cd trove-cache
mkdir -p public
aws s3 cp s3://moocho-test/public/little-prince.json ./public/
aws s3 cp s3://moocho-test/troves .
