#!/usr/bin/env bash
# Phase 3 — "The Over-Privileged Role": EC2 role with AdministratorAccess.
set -euo pipefail
cd "$(dirname "$0")"
source ./00_config.sh

echo "== Creating IAM role: $ROLE_NAME =="
aws iam create-role \
  --role-name "$ROLE_NAME" \
  --assume-role-policy-document file://../policies/ec2-trust-policy.json \
  --description "Lazy-developer EC2 role for the cloud security lab (intentionally over-privileged)"

echo "== Attaching AdministratorAccess (intentional misconfiguration) =="
aws iam attach-role-policy \
  --role-name "$ROLE_NAME" \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

echo "== Creating instance profile and adding the role =="
aws iam create-instance-profile --instance-profile-name "$INSTANCE_PROFILE_NAME"
aws iam add-role-to-instance-profile \
  --instance-profile-name "$INSTANCE_PROFILE_NAME" \
  --role-name "$ROLE_NAME"

echo "== Waiting for IAM propagation (10s) =="
sleep 10

echo "== Done. Role ARN: =="
aws iam get-role --role-name "$ROLE_NAME" --query 'Role.Arn' --output text
