# Cloud Security & Posture Audit Project

A self-contained, intentionally-vulnerable AWS lab for practicing cloud
vulnerability assessment (VA) and penetration testing (PT). You build the
misconfigurations yourself, attack them from a Kali attacker box, then audit
them with Scout Suite and Prowler and write up findings as a portfolio-grade
report.

**Run this only in your own sandbox AWS account. Tear it down when you're
done (see `scripts/99_cleanup.sh`).**

## Layout

```
cloud-security-audit-project/
├── README.md                  <- you are here
├── scripts/                   <- setup & teardown automation
│   ├── 00_config.sh           <- edit this first (names, region, IPs)
│   ├── 01_create_bucket.sh    <- "The Leaky Bucket"
│   ├── 02_create_iam_role.sh  <- "The Over-Privileged Role"
│   ├── 03_launch_ec2.sh       <- "The Open Firewall" + target host
│   └── 99_cleanup.sh          <- tear everything down
├── policies/                  <- IAM / S3 JSON policy documents
│   ├── bucket-public-read-policy.json
│   ├── ec2-trust-policy.json
│   └── user-data.sh           <- bootstrap script for the EC2 target
├── attack-playbook/            <- the PT walkthrough, Kali side
│   ├── 01_recon.md
│   ├── 02_initial_access.md
│   ├── 03_credential_theft.md
│   └── 04_exfiltration_pacu.md
├── audit/                      <- the VA side
│   ├── run_scoutsuite.sh
│   ├── run_prowler.sh
│   └── mitre_attack_mapping.md
└── report/
    └── report_template.md      <- portfolio report skeleton
```

## Quick start

1. `aws configure` with your sandbox account's credentials.
2. Edit `scripts/00_config.sh` — set your name/suffix, region, and your own
   public IP (used later if you want to scope SSH instead of 0.0.0.0/0 for
   the "fixed" comparison run).
3. Run the setup scripts in order: `01_create_bucket.sh`,
   `02_create_iam_role.sh`, `03_launch_ec2.sh`.
4. Work through `attack-playbook/` from your Kali box.
5. Run the two audit scripts in `audit/`.
6. Fill in `report/report_template.md` with your findings and screenshots.
7. Run `scripts/99_cleanup.sh` to destroy everything.

## Cost note

Everything here fits AWS Free Tier (t2.micro EC2, S3 standard storage for a
few KB file). Set a Budget alert anyway — see Phase 1 in the roadmap.
