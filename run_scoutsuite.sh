#!/usr/bin/env bash
# Phase 7.1 — Scout Suite audit. Run this with your normal (non-stolen) AWS creds.
set -euo pipefail

if ! command -v scout >/dev/null 2>&1; then
  echo "Installing Scout Suite..."
  pip install scoutsuite
fi

echo "== Running Scout Suite against your AWS account =="
scout aws --report-dir ./scoutsuite-report

echo "== Done. Open ./scoutsuite-report/scoutsuite-results/*.html in a browser. =="
echo "Look specifically for: S3 bucket public access findings, IAM overly-permissive"
echo "role findings, and EC2 security group findings — these should match what you"
echo "deliberately built in Phases 2-4."
