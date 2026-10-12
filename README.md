# Cloud-Security-Posture-Audit-Penetration-Test-AWS
Overview

This project simulates a realistic cloud breach end to end, in an account you control:

Build three common real-world AWS misconfigurations.
Attack them from a Kali Linux box — recon, initial access, credential theft via instance metadata, privilege enumeration, and data exfiltration.
Audit the same environment independently with Scout Suite and Prowler, to confirm the scanners catch what was deliberately broken.
Report the findings in a structured format with CIS/NIST compliance mapping and remediation guidance — the actual portfolio deliverable.
Architecture
[Attacker Node: Kali Linux]
       │
       ├───► (Exploits Port 22 open to 0.0.0.0/0) ───► [Target: Ubuntu EC2]
       │                                                      │ (Steals IAM role credentials via IMDS)
       ▼                                                      ▼
(Uses Pacu / AWS CLI) ────────────────────────────────► [Target: Public S3 Bucket]
                                                         (Exfiltrates confidential_salaries.csv)
Tech Stack
Category	Tool	Purpose
Target infrastructure	AWS Free Tier	Host environment
Target host	Ubuntu 22.04 (EC2)	Simulated corporate server
VA — multi-cloud audit	Scout Suite	Visual HTML misconfiguration dashboard
VA — benchmarking	Prowler	CIS AWS Foundations / NIST checks
Attacker machine	Kali Linux	Offensive toolset
PT — cloud exploitation	Pacu	AWS privilege enumeration & exfiltration
PT — manual exploitation	AWS CLI	Direct resource querying/exploitation

All of the above run entirely on AWS Free Tier — no paid subscriptions required.

Repository Layout
cloud-security-audit-project/
├── README.md                   <- you are here
├── scripts/                    <- setup & teardown automation
│   ├── 00_config.sh            <- edit first (names, region, your IP)
│   ├── 01_create_bucket.sh     <- builds "The Leaky Bucket"
│   ├── 02_create_iam_role.sh   <- builds "The Over-Privileged Role"
│   ├── 03_launch_ec2.sh        <- builds "The Open Firewall" + target host
│   └── 99_cleanup.sh           <- tears everything down
├── policies/                   <- IAM / S3 JSON policy documents
│   ├── bucket-public-read-policy.json
│   ├── ec2-trust-policy.json
│   └── user-data.sh            <- EC2 bootstrap script
├── attack-playbook/             <- the PT walkthrough (Kali side)
│   ├── 01_recon.md
│   ├── 02_initial_access.md
│   ├── 03_credential_theft.md
│   └── 04_exfiltration_pacu.md
├── audit/                       <- the VA side
│   ├── run_scoutsuite.sh
│   ├── run_prowler.sh
│   └── mitre_attack_mapping.md
└── report/
    └── report_template.md       <- portfolio report skeleton
Prerequisites
An AWS account you control, with a budget alert set (sandbox/free-tier recommended — not production)
AWS CLI v2, configured (aws configure)
Kali Linux (local VM or a second small EC2 instance) with python3-pip
Python 3.9+ for Scout Suite and Prowler
Quick Start
bash
git clone <this-repo-url>
cd cloud-security-audit-project

# 1. Configure your AWS CLI
aws configure

# 2. Edit scripts/00_config.sh — set your name suffix, region, etc.

# 3. Build the lab, in order
cd scripts
./01_create_bucket.sh
./02_create_iam_role.sh
./03_launch_ec2.sh

# 4. Attack it — walk through attack-playbook/ from your Kali box

# 5. Audit it
cd ../audit
./run_scoutsuite.sh
./run_prowler.sh

# 6. Write it up — fill in report/report_template.md

# 7. Tear it down
cd ../scripts
./99_cleanup.sh
Attack Chain Summary
Step	Action	Technique
1	Port scan reveals SSH open to the world	Active Scanning
2	SSH access via a leaked private key	Unsecured Credentials: Private Keys
3	Pull temp IAM creds from the instance metadata service	Unsecured Credentials: Cloud Instance Metadata API
4	Enumerate permissions with Pacu — confirm admin access	Account Discovery: Cloud Account
5	Discover the public S3 bucket	Cloud Storage Object Discovery
6	Exfiltrate confidential_salaries.csv	Data from Cloud Storage

Full walkthrough with commands: attack-playbook/.

Findings
#	Finding	Severity
1	S3 bucket publicly readable, contains sensitive data	Critical
2	SSH (22) open to 0.0.0.0/0 on target EC2	High
3	EC2 IAM role has AdministratorAccess (over-privileged)	Critical
4	IMDSv1 enabled (no session-token requirement)	Medium

Each finding's root cause, evidence, and remediation is detailed in report/report_template.md.

MITRE ATT&CK Mapping

See audit/mitre_attack_mapping.md for the full technique-by-technique table (T1595, T1552.004, T1552.005, T1087.004, T1619, T1530).

Cleanup
bash
cd scripts
./99_cleanup.sh

Destroys the EC2 instance, security group, key pair, IAM role/instance profile, and empties + deletes the S3 bucket. Run this as soon as you're done — don't leave a publicly readable bucket or an admin-privileged, internet-facing instance running.

Cost

Everything here fits comfortably within the AWS Free Tier: one t2.micro EC2 instance and a few KB of S3 storage. Set an AWS Budget alert regardless, as a safety net.
