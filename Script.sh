# Cline Task: SCSEC-7954 Phase 2 — write, run, and verify the OpenVPN configuration AUTONOMOUSLY

Work end to end without waiting for my input. Make the best call using the decisions below.
Only stop and ask if you hit something that would be destructive or genuinely ambiguous in
a way these instructions don't cover (see "When to stop" at the end). Otherwise, proceed
through all steps and give me a single final report.

## Decisions (already made — apply them, don't re-ask)
1. Base this on the `openvpn-configure-userauth.yml` reference (local user/password + cert
   auth). Do NOT use domainauth/aad/ldapauth/hardware-mfa (need infra/secrets we don't have)
   or pipeline-ssm (AMI-build, wrong purpose).
2. Trim the chain — do NOT include aws-cloudwatch-agent or aws-ssm-agent pre_tasks from the
   reference. The ticket only requires configuring OpenVPN. Include only:
   customize_openvpn (userauth) -> openvpn role.
3. Variable overrides:
   - openvpn_create_virtualenv: false
   - manage_iptables_rules: false   (SG handles the perimeter; don't let the role rewrite
     iptables over a remote SSH session)
   - clients: ['c5425849']
   - Leave openvpn_redirect_gateway, openvpn_port, openvpn_proto, openvpn_server_network,
     and all cipher/TLS settings at role defaults. Full-tunnel default is fine (split-tunnel
     was a 7960 bonus, not a 7954 requirement).
4. Apply the 7960 root-PATH fix proactively: the role runs `aws configure set region` as
   root; root's sudo secure_path may lack the AWS CLI dir. Symlink `aws` into a dir already
   on root's secure_path before the role runs, same pattern as the 7960 playbook.

## Target (pull IPs fresh — EIP is detached, public IP changes on restart)
- VPN box instance ID: i-039020ae0cf081a8f, AMI Golden-SCS-Ubuntu-20.04-OpenVPN.
- SSH user: ec2-user (confirmed in 7960; NOT ubuntu). Key: ~/.ssh/id_ed25519.
- Connect DIRECTLY — this box has a public IP, no jump needed.
- export AWS_PROFILE=shc-dev-build-l ; region us-east-2 ; account 753386176131.
- If `aws sts get-caller-identity` fails with expired/no creds, STOP and tell me to run
  saml2aws (you can't supply my TOTP). That's the one hard external dependency.
- SG sg-00abe7e84eceb8f00 already allows SSH/22 and UDP/1194. Do NOT open new ports.

## Step 1 — Fix inventory structure (do first)
Current ~/training/ansible-bastion/inventory/hosts.yml has the bastion ProxyCommand under
the global `all: vars:` block, which would wrongly apply to the VPN box (causing a jump
loop). Restructure so:
- Jump/ProxyCommand settings apply ONLY to the `bastion` group.
- Add a `vpn` group with the VPN box, connecting directly (no ProxyCommand), user ec2-user.
- Pull the current public IP from AWS and use Ansible env-lookup or a written-in value that
  resolves at runtime (not a dead ${VAR} literal — that bug bit us before).
Verify with `ansible-inventory --graph` and `ansible vpn -m ping`. If ping fails, diagnose
in this order before assuming anything else: (a) is the instance running (describe-instances
State) — start it if stopped; (b) is the public IP current; (c) does SG allow SSH from my
current public IP `curl -s https://checkip.amazonaws.com` — if my IP changed, add it to the
SG via authorize-security-group-ingress (note the drift, don't destroy anything). Fix
whichever it is and retry. Do not swap the AMI or rebuild the instance.

## Step 2 — Read-only recon (document before-state, change nothing)
Direct SSH as ec2-user:
  ls -la /etc/openvpn/keys/ 2>&1
  systemctl status 'openvpn@*' 2>&1
  sudo iptables -L -n 2>&1 | head -30
Record the output for the final report. Then proceed — do not wait.

## Step 3 — Write the playbook
Create ~/training/ansible-bastion/vpn-configure.yml in the SAME project (reuse ansible.cfg,
group_vars, roles_path). Target `hosts: vpn`, gather_facts: true, become: true. Use plain
include_role calls with explicit vars, trimmed chain + overrides above. Put the root-PATH
symlink fix as an early task. Add group_vars/vpn.yml if cleaner than inlining vars.

## Step 4 — Run
cd ~/training/ansible-bastion && ansible-playbook vpn-configure.yml
If a task fails, attempt reasonable self-correction based on the error and the 7960
precedents (root PATH, missing package -> dnf/apt install it, python interpreter mismatch),
re-run, and note what you changed. If aws-cloudwatch-agent/aws-ssm-agent get pulled in via
an unexpected dependency and fail on unreachable S3/repo endpoints, that's expected off-VPN
— strip them from the chain and re-run rather than treating it as a blocker.

## Step 5 — Verify
  ansible vpn -b -m command -a "systemctl status 'openvpn@*'"
  ansible vpn -b -m command -a 'ls -la /etc/openvpn/keys/'
  ansible vpn -b -m shell -a 'sudo cat /etc/openvpn/openvpn_udp_1194.conf'
Confirm the client .ovpn was generated (role fetches to /tmp/ansible/<client>/<host>.ovpn on
this Mac) and report its path.

## When to stop and ask (only these)
- AWS creds expired (needs my TOTP for saml2aws).
- The only path forward would destroy/terminate an instance or delete infra.
- The playbook needs a real secret/credential not derivable from the repo or these notes.
- Repeated (3+) failures on the same task after reasonable self-correction attempts.
Otherwise: proceed through all steps and deliver ONE final report — recon before-state,
what you wrote, the play recap (ok/changed/failed), any self-corrections made, verification
output, and the .ovpn path.

## Constraints
- No new SG ports. No instance stop/restart (a service restart via the role is fine). No
  destroy. Reuse the existing project, don't create a parallel one. Don't swap/rebuild AMIs.
