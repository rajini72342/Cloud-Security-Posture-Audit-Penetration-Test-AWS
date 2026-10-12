#!/usr/bin/env bash
# Shared config — source this from every other script:
#   source "$(dirname "$0")/00_config.sh"

set -euo pipefail

# --- EDIT THESE ---
export LAB_NAME_SUFFIX="rajanikanth"          # used to make resource names unique
export AWS_REGION="ap-south-1"                 # Mumbai; change if you prefer
export KEY_PAIR_NAME="cloud-audit-lab-key"     # will be created if missing
export MY_IP_CIDR="$(curl -s https://checkip.amazonaws.com)/32"  # your real IP, for the "fixed" comparison

# --- DERIVED NAMES (don't need to edit) ---
export BUCKET_NAME="corp-internal-backup-${LAB_NAME_SUFFIX}"
export ROLE_NAME="EC2-App-Role-Legacy-${LAB_NAME_SUFFIX}"
export INSTANCE_PROFILE_NAME="EC2-App-Role-Legacy-${LAB_NAME_SUFFIX}-profile"
export SG_NAME="leaky-cloud-target-sg-${LAB_NAME_SUFFIX}"
export INSTANCE_NAME="leaky-cloud-target-${LAB_NAME_SUFFIX}"

echo "Config loaded: bucket=$BUCKET_NAME region=$AWS_REGION"
