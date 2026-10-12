# MITRE ATT&CK Mapping Summary

| Step | Technique | ID | Tactic |
|---|---|---|---|
| Port/service scan of target | Active Scanning | T1595 | Reconnaissance |
| SSH access via leaked key | Unsecured Credentials: Private Keys | T1552.004 | Initial Access / Credential Access |
| IMDS credential pull | Unsecured Credentials: Cloud Instance Metadata API | T1552.005 | Credential Access |
| IAM enumeration (Pacu) | Account Discovery: Cloud Account | T1087.004 | Discovery |
| S3 bucket discovery (Pacu) | Cloud Storage Object Discovery | T1619 | Discovery |
| File exfiltration | Data from Cloud Storage | T1530 | Collection / Exfiltration |

Use this table directly in the report's "Attack Narrative" section —
it's the kind of structured mapping that reads well to a hiring manager
reviewing a SOC/security-analyst portfolio piece.
