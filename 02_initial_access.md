# Phase 6.2 — Initial Access (from Kali)

Since this is your own lab, "credential compromise" is simulated honestly
rather than brute-forced: in a real engagement an attacker would obtain the
SSH private key through phishing, a leaked repo, a misconfigured backup, etc.
Here, copy the `.pem` file you generated in `scripts/03_launch_ec2.sh` onto
your Kali box as the stand-in for "the attacker got hold of a leaked key" —
that's the realistic initial-access vector worth documenting, not a live
brute-force against your own box.

```bash
# On Kali, with the copied key:
chmod 400 cloud-audit-lab-key.pem
TARGET_IP=$(cat ../scripts/.public_ip)
ssh -i cloud-audit-lab-key.pem ubuntu@"$TARGET_IP"
```

**MITRE ATT&CK mapping:** T1078 — Valid Accounts (Cloud Accounts variant
doesn't quite fit here; this is T1078.004 adjacent via a leaked SSH key —
note it as T1552.004, Unsecured Credentials: Private Keys, in your
report).

Once you have a shell on the target, move to
`03_credential_theft.md`.
