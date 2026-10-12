# Cloud Security & Posture Audit Report
**AWS "Leaky Cloud" Lab — Vulnerability Assessment & Penetration Test**

Prepared by: Aluru Rajanikanth
Date: _[fill in]_
Scope: Self-hosted AWS sandbox account (account ID redacted), single VPC, one EC2 target, one S3 bucket.

---

## 1. Executive Summary

_2-4 sentences. Example shape:_
This engagement simulated an external attacker chain against a deliberately
misconfigured AWS environment, combining network exposure, credential
exposure via instance metadata, and an over-privileged IAM role to achieve
full administrative compromise and exfiltrate a sensitive file from a
public S3 bucket. Three critical findings were identified and are detailed
below, each with a corresponding remediation.

**Overall Risk Rating:** Critical

| # | Finding | Severity |
|---|---|---|
| 1 | S3 bucket publicly readable, contains sensitive data | Critical |
| 2 | SSH (22) open to 0.0.0.0/0 on target EC2 | High |
| 3 | EC2 IAM role has `AdministratorAccess` (over-privileged) | Critical |
| 4 | IMDSv1 enabled (no session-token requirement) | Medium |

---

## 2. Attack Narrative

_Walk through Phases 6.1–6.4 from the playbook in your own words. Include
screenshots for:_
- `nmap` scan output
- SSH login to the target
- IMDS `curl` pulling the credentials
- `aws sts get-caller-identity` confirming the assumed role
- Pacu's `iam__enum_permissions` output
- The exfiltrated `confidential_salaries.csv` contents

See `audit/mitre_attack_mapping.md` for the full ATT&CK technique table —
paste it in here.

---

## 3. Vulnerability Assessment Findings (Scout Suite + Prowler)

_For each finding, use this structure:_

### Finding 1: S3 Bucket Publicly Accessible
- **Tool(s):** Scout Suite, Prowler
- **Severity:** Critical
- **Description:** _what the scanner flagged, in your own words_
- **Evidence:** _screenshot of the Scout Suite dashboard panel / Prowler CSV row_
- **Remediation:** Re-enable S3 Block Public Access at the bucket (and
  account) level; remove the wildcard `Principal: "*"` statement from the
  bucket policy; if public distribution is genuinely required, front the
  bucket with CloudFront + signed URLs instead.

### Finding 2: SSH Open to the Internet
- **Severity:** High
- **Remediation:** Restrict the security group's port 22 rule to a bastion
  host or known CIDR ranges (e.g. your office/VPN IP); prefer AWS Systems
  Manager Session Manager over direct SSH entirely.

### Finding 3: Over-Privileged IAM Role
- **Severity:** Critical
- **Remediation:** Replace `AdministratorAccess` with a least-privilege
  policy scoped to exactly what the application needs (e.g. read/write to
  one named S3 prefix); use IAM Access Analyzer to generate a draft policy
  from actual CloudTrail usage.

### Finding 4: IMDSv1 Enabled
- **Severity:** Medium
- **Remediation:** Enforce IMDSv2 (`aws ec2 modify-instance-metadata-options
  --http-tokens required`) so credential theft requires a session-token
  round trip, closing the simplest SSRF-to-credential-theft path.

---

## 4. Remediation Summary Table

| Finding | Fix | Priority |
|---|---|---|
| Public S3 bucket | Re-enable Block Public Access, remove public policy | P0 |
| Over-privileged IAM role | Scope to least privilege | P0 |
| Open SSH | Restrict security group source CIDR | P1 |
| IMDSv1 | Enforce IMDSv2 | P2 |

---

## 5. Compliance Mapping

_Pull directly from the Prowler CIS/NIST output — list which specific CIS
AWS Foundations Benchmark controls (e.g. 1.x IAM, 2.x Logging, 5.x
Networking) and which NIST CSF categories each finding violates._

---

## 6. Conclusion

_Short closing paragraph: overall posture, what a real remediation sprint
would prioritize first, and what you'd test next (e.g. CloudTrail logging
gaps, GuardDuty detection coverage of this exact attack chain)._

---

*Lab environment torn down post-assessment via `scripts/99_cleanup.sh`.*
