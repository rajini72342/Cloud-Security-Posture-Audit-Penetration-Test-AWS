#!/usr/bin/env bash
# Phase 4 — "The Open Firewall" + target EC2 with IMDS-reachable admin role.
set -euo pipefail
cd "$(dirname "$0")"
source ./00_config.sh

echo "== Creating key pair: $KEY_PAIR_NAME =="
if ! aws ec2 describe-key-pairs --key-names "$KEY_PAIR_NAME" --region "$AWS_REGION" >/dev/null 2>&1; then
  aws ec2 create-key-pair --key-name "$KEY_PAIR_NAME" --region "$AWS_REGION" \
    --query 'KeyMaterial' --output text > "${KEY_PAIR_NAME}.pem"
  chmod 400 "${KEY_PAIR_NAME}.pem"
  echo "Saved private key to scripts/${KEY_PAIR_NAME}.pem (keep this off any public attacker box except as your own 'leaked credential' prop)"
else
  echo "Key pair already exists, skipping."
fi

DEFAULT_VPC_ID=$(aws ec2 describe-vpcs --filters Name=is-default,Values=true \
  --region "$AWS_REGION" --query 'Vpcs[0].VpcId' --output text)

echo "== Creating security group: $SG_NAME (open SSH — intentional) =="
SG_ID=$(aws ec2 create-security-group \
  --group-name "$SG_NAME" \
  --description "Leaky cloud lab target SG" \
  --vpc-id "$DEFAULT_VPC_ID" \
  --region "$AWS_REGION" \
  --query 'GroupId' --output text)

aws ec2 authorize-security-group-ingress \
  --group-id "$SG_ID" --protocol tcp --port 22 --cidr 0.0.0.0/0 --region "$AWS_REGION"
aws ec2 authorize-security-group-ingress \
  --group-id "$SG_ID" --protocol tcp --port 80 --cidr 0.0.0.0/0 --region "$AWS_REGION"

echo "== Finding latest Ubuntu 22.04 AMI =="
AMI_ID=$(aws ec2 describe-images --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" \
            "Name=state,Values=available" \
  --region "$AWS_REGION" \
  --query 'sort_by(Images, &CreationDate)[-1].ImageId' --output text)

echo "== Launching t2.micro instance: $INSTANCE_NAME =="
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id "$AMI_ID" \
  --instance-type t2.micro \
  --key-name "$KEY_PAIR_NAME" \
  --security-group-ids "$SG_ID" \
  --iam-instance-profile Name="$INSTANCE_PROFILE_NAME" \
  --user-data file://../policies/user-data.sh \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${INSTANCE_NAME}}]" \
  --region "$AWS_REGION" \
  --query 'Instances[0].InstanceId' --output text)

echo "Instance launching: $INSTANCE_ID — waiting for it to be running..."
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID" --region "$AWS_REGION"

PUBLIC_IP=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --region "$AWS_REGION" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

echo "== Done =="
echo "Instance ID : $INSTANCE_ID"
echo "Public IP   : $PUBLIC_IP"
echo "SSH         : ssh -i ${KEY_PAIR_NAME}.pem ubuntu@${PUBLIC_IP}"
echo "$INSTANCE_ID" > .instance_id
echo "$SG_ID" > .sg_id
echo "$PUBLIC_IP" > .public_ip
