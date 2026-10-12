#!/usr/bin/env bash
# Phase 7.2 — Prowler audit (CIS / NIST benchmarking). Run with your normal creds.
set -euo pipefail

if ! command -v prowler >/dev/null 2>&1; then
  echo "Installing Prowler..."
  pip install prowler
fi

echo "== Running Prowler (CIS AWS Foundations benchmark) =="
prowler aws --compliance cis_2.0_aws -M csv json-asff html -o ./prowler-report

echo "== Done. Reports are in ./prowler-report/ =="
echo "Key checks to pull into your report: s3 bucket public access checks,"
echo "iam policy allows admin privileges, ec2 security group ssh open to 0.0.0.0/0."
