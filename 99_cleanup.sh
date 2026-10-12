#!/usr/bin/env bash
# Tear down every resource created by this lab. Run this when you're done.
set -euo pipefail
cd "$(dirname "$0")"
source ./00_config.sh

echo "== Terminating EC2 instance =="
if [ -f .instance_id ]; then
  INSTANCE_ID=$(cat .instance_id)
  aws ec2 terminate-instances --instance-ids "$INSTANCE_ID" --region "$AWS_REGION" || true
  aws ec2 wait instance-terminated --instance-ids "$INSTANCE_ID" --region "$AWS_REGION" || true
fi

echo "== Deleting security group =="
if [ -f .sg_id ]; then
  SG_ID=$(cat .sg_id)
  aws ec2 delete-security-group --group-id "$SG_ID" --region "$AWS_REGION" || true
fi

echo "== Deleting key pair =="
aws ec2 delete-key-pair --key-name "$KEY_PAIR_NAME" --region "$AWS_REGION" || true
rm -f "${KEY_PAIR_NAME}.pem"

echo "== Removing instance profile / role =="
aws iam remove-role-from-instance-profile \
  --instance-profile-name "$INSTANCE_PROFILE_NAME" --role-name "$ROLE_NAME" || true
aws iam delete-instance-profile --instance-profile-name "$INSTANCE_PROFILE_NAME" || true
aws iam detach-role-policy --role-name "$ROLE_NAME" \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess || true
aws iam delete-role --role-name "$ROLE_NAME" || true

echo "== Emptying and deleting S3 bucket =="
aws s3 rm "s3://${BUCKET_NAME}" --recursive || true
aws s3api delete-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION" || true

rm -f .instance_id .sg_id .public_ip
echo "== Cleanup complete =="
