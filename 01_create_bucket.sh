#!/usr/bin/env bash
# Phase 2 — "The Leaky Bucket": public S3 bucket with a confidential file in it.
set -euo pipefail
cd "$(dirname "$0")"
source ./00_config.sh

echo "== Creating bucket: $BUCKET_NAME in $AWS_REGION =="
if [ "$AWS_REGION" = "us-east-1" ]; then
  aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION"
else
  aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION" \
    --create-bucket-configuration LocationConstraint="$AWS_REGION"
fi

echo "== Disabling Block Public Access =="
aws s3api put-public-access-block --bucket "$BUCKET_NAME" \
  --public-access-block-configuration \
  BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false

echo "== Applying public-read bucket policy =="
TMP_POLICY=$(mktemp)
sed "s/__BUCKET_NAME__/${BUCKET_NAME}/g" ../policies/bucket-public-read-policy.json > "$TMP_POLICY"
aws s3api put-bucket-policy --bucket "$BUCKET_NAME" --policy "file://$TMP_POLICY"
rm -f "$TMP_POLICY"

echo "== Uploading dummy confidential file =="
cat > /tmp/confidential_salaries.csv <<EOF
employee_id,name,department,salary_usd
1001,A. Sharma,Engineering,142000
1002,R. Iyer,Sales,98000
1003,P. Nair,Finance,131000
EOF
aws s3 cp /tmp/confidential_salaries.csv "s3://${BUCKET_NAME}/confidential_salaries.csv"
rm -f /tmp/confidential_salaries.csv

echo "== Verifying public access (should return the CSV content) =="
PUBLIC_URL="https://${BUCKET_NAME}.s3.${AWS_REGION}.amazonaws.com/confidential_salaries.csv"
echo "Public URL: $PUBLIC_URL"
curl -s "$PUBLIC_URL" || echo "(curl failed — check bucket policy propagation, can take ~30s)"

echo "== Done. Bucket $BUCKET_NAME is now publicly readable. =="
