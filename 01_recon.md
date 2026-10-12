# Phase 6.1 — Reconnaissance (from Kali)

**Target:** the public IP printed by `scripts/03_launch_ec2.sh` (also saved
in `scripts/.public_ip`).

```bash
TARGET_IP=$(cat ../scripts/.public_ip)

# Port scan
nmap -sV -p- "$TARGET_IP"
```

Expected findings to note in your report:
- Port 22 (SSH) open to the world — no source restriction on the security group.
- Port 80 (nginx) open, serving a generic "Internal Portal" page — suggests a corporate web app, a plausible pivot target.

This maps to **MITRE ATT&CK T1595 — Active Scanning** (attacker-side) and
is the finding you'll later cross-reference against the Scout
Suite/Prowler output in `audit/`.
