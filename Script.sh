Good call — Cline can read the actual repo files, so let it do the finding *and* the writing this time, with me setting it up so it doesn't have to ask you the same questions again.

Here's a complete task to hand to Cline for **SCSEC-7954**.

---

# Cline Task: SCSEC-7954 — OpenVPN Configuration

## Goal
Ticket requirement: "Use the Ansible Roles and Playbooks to configure the public VPN instance." This is the last of the training tickets (7952→7958→7957→7956→7955→7960→**7954**). 7960 (bastion) is already done and applied.

## Do this in two phases. Phase 1 = extract and report back to me before writing anything. Phase 2 = only after I confirm.

## Environment (same as 7960 — already proven working)
- Control machine: Mac, ansible runs from `source ~/.venvs/ansible/bin/activate` (Python 3.12, ansible-core 2.21.4, boto3 installed).
- Project lives at `~/training/ansible-bastion/` — reuse this same project (ansible.cfg, inventory, group_vars) rather than creating a new one, since the target VPN box is in the same VPC/account.
- AWS: `export AWS_PROFILE=shc-dev-build-l`, region us-east-2, account 753386176131.
- Terraform state for IPs: `cd ~/training/terraform/rework && terraform output`.

## The target instance — the public VPN box
- Instance ID: `i-039020ae0cf081a8f`
- AMI: **Golden-SCS-Ubuntu-20.04-OpenVPN** (a golden, pre-hardened image — likely already has OpenVPN installed; this ticket is probably about *configuring* it, not installing from scratch — verify, don't assume)
- **SSH login user is `ec2-user`** (confirmed during 7960 debugging — NOT `ubuntu`, despite it being an Ubuntu-based AMI)
- Public IP changes on restart — its Elastic IP is currently detached (known issue, separate from this ticket). Always pull the current public IP fresh:
  ```bash
  aws ec2 describe-instances --region us-east-2 --instance-ids i-039020ae0cf081a8f \
    --query 'Reservations[0].Instances[0].PublicIpAddress' --output text
  ```
- Security group `sg-00abe7e84eceb8f00` (`vpn-sg-c5425849`) already allows: SSH tcp/22 from `208.127.240.18/32`, OpenVPN udp/1194 from `208.127.240.18/32`. If configuring OpenVPN needs additional ports open (e.g. tcp/443 for TLS mode, port 943 for an admin UI — check the role/AMI for what it actually uses), flag this to me rather than silently opening ports.
- No jump/ProxyJump needed for this box — it has a public IP, connect directly.

## PHASE 1 — Extraction (do this first, report back, do not write the playbook yet)

### Step 1: Check what's already cloned locally
```bash
find ~/ansible/shared-roles -maxdepth 1 -iname "*openvpn*" 2>/dev/null
find ~/main -type d -iname "*openvpn*" 2>/dev/null
find ~/ansible -maxdepth 2 -iname "*openvpn*" 2>/dev/null
```

### Step 2: If not found locally, clone from GitLab
The `bastion`, `disk-management`, `repository-management` roles used for 7960 live in `scs/shared/ansible/roles` (already cloned at `~/ansible/shared-roles`). The `bastion.yml` reference playbook (author Mark Carey) lives in `scs/security/ansible/playbooks`. The `openvpn` role and an `openvpn.yml` reference playbook are expected to be **siblings of that**, likely in `scs/security/ansible/roles` and `scs/security/ansible/playbooks`.

**Important — do not guess the clone path.** A previous attempt to clone `scs/shared/ansible` (without `/roles` on the end) failed with "project not found" because it was a GitLab *subgroup* (a folder), not a repo — the actual repo was one level deeper (`scs/shared/ansible/roles`). Get the exact clone URL from the GitLab UI's **Code** button for whichever repo actually holds `openvpn.yml` and the `openvpn` role, rather than constructing the path from the pattern above.

```bash
mkdir -p ~/ansible/security-roles
git clone <EXACT_URL_FROM_GITLAB_UI> ~/ansible/security-roles
```

### Step 3: Read and report — quote exact values, say "not found in files" if absent, do not guess or infer beyond what's written

Report on the **`openvpn` role**:
1. Does it **install** OpenVPN packages, or does it assume OpenVPN is already installed (i.e., does it check for an existing install / skip install tasks on a golden image)? Quote the relevant task names/conditions.
2. Every variable in `defaults/main.yml` and `vars/main.yml`, with its default value — especially: listening port/protocol, cipher/TLS-auth settings, server subnet/CIDR for VPN clients, whether it does split-tunnelling or routes-all-traffic, CA/PKI cert generation (does it generate certs, or expect existing ones?), client config generation.
3. What templates it renders and to what paths (e.g. `server.conf`, `client.ovpn`, systemd unit files).
4. `meta/main.yml` — dependencies on other roles, required collections.
5. Minimum `gather_facts`/`become` requirements.
6. Any variable resembling `bastion_hostname`-style naming for this role — anything that needs employee ID / a per-user identifier.

Report on the **`openvpn.yml` reference playbook** (if it exists — check alongside `bastion.yml`):
7. Full role-chain it calls, in order — same pattern as `bastion.yml`, which chained `repository-management → fips → aws-cloudwatch-agent → iptables → domain-join → bastion → reboot`. We do NOT want `domain-join` (prompts for an AD password we don't have) or other roles unrelated to the ticket — list every role it chains and flag which ones look like they'd need credentials/secrets we don't have.
8. Any vars_files or vars_from patterns it uses (the `bastion.yml` example used `vars_from: business/sms.yml`).

Also check: does anything in the role or playbook reference **split tunnelling** specifically? 7960's ticket text mentioned "configure OpenVPN for split tunnelling" as a bonus objective — if 7954 and that bonus overlap, note it so we don't do redundant work.

**Stop here and report all of the above back before writing any Ansible code.**

## PHASE 2 — Only after I review Phase 1 findings and confirm

I will come back with instructions once I've seen what's actually in the role. Do not proceed to writing `openvpn.yml`, modifying the inventory, or running anything against the VPN box until then.

## Constraints (same as 7960)
- Do not install/reinstall OpenVPN from scratch if the golden image already has it working — that would fight the point of using a golden image. Configure, don't reinstall, unless the extraction shows the role/ticket genuinely calls for it.
- Do not restart or stop the VPN instance.
- Do not destroy any infrastructure.
- If opening new security group ports is needed, tell me which ports and why before applying — don't just open them.
- Reuse `~/training/ansible-bastion/` as the project (ansible.cfg, group_vars, roles_path already point at the right places) rather than creating a parallel structure.

---

Send that to Cline, and once it reports back Phase 1, paste the findings here and I'll write the actual `openvpn.yml` playbook grounded in what the role really does — same approach that got 7960 right.
