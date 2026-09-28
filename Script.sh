# Cline Task: Debug SSH ProxyJump failure — VPN jump host can't reach private bastion

## Goal
Get Ansible able to reach a private EC2 instance ("bastion") through a public EC2 instance ("VPN box") as an SSH jump host, so I can run `ansible-playbook bastion.yml` for training ticket SCSEC-7960. Everything runs **locally from my Mac** against AWS account `shc-dev-build-l`.

## Environment
- Machine: SAP MacBook Pro, arm64, macOS 26.2 "Tahoe", zsh.
- Working dir: `~/training/ansible-bastion`
- Python: Ansible runs from a uv venv at `~/.venvs/ansible` (Python 3.12), `ansible-core 2.21.4`, `boto3 1.43.103` importable. Activate with `source ~/.venvs/ansible/bin/activate`.
- AWS: profile `shc-dev-build-l`, account `753386176131`, role `AWS-AutomationEngineering`, region `us-east-2`. Auth via `saml2aws login -a shc-dev-build-l --mfa-token=<TOTP>` then `export AWS_PROFILE=shc-dev-build-l`. `aws sts get-caller-identity` confirmed working and returns `753386176131`.
- SSH key: `~/.ssh/id_ed25519`, fingerprint `SHA256:aJZLWCdJGbKUe2Ru/tm8cICTjfoIBr6lhRiMzE2qA4`.

## The two instances (Terraform "rework" stack, `~/training/terraform/rework`)
- **VPN box (public jump host):** instance ID `i-039020ae0cf081a8f`, current public IP `3.19.59.179`, private IP `10.10.1.x`, hostname `ip-10-10-1-173`, type t3.small, AZ us-east-2b, AMI is a Golden-SCS Ubuntu 20.04 OpenVPN image. **SSH login user is `ec2-user`** (NOT `ubuntu` — confirmed by testing).
- **Private box (the bastion, target):** instance ID `i-01640cbe938390708`, private IP `10.10.2.217`, no public IP, stock RHEL 9, SSH login user `ec2-user`.
- VPC ID: `vpc-0224246255ffa7f6`, VPC CIDR `10.10.0.0/16`.
- Security groups:
  - VPN box SG: `sg-00abe7e84eceb8f00` (name `vpn-sg-c5425849`). Inbound: SSH tcp/22 from `208.127.240.18/32`, OpenVPN udp/1194 from `208.127.240.18/32`.
  - Private box SG: `sg-014da667cd62ccec5` (name references private).
- My laptop public IP (admin_cidr): `208.127.240.18`.

Terraform outputs from the rework stack:
```
instance_ids = { "private" = "i-01640cbe938390708", "vpn" = "i-039020ae0cf081a8f" }
private_security_group_id = "sg-014da667cd62ccec5"
vpn_security_group_id     = "sg-00abe7e84eceb8f00"
subnet_ids = { "private" = "subnet-0e252e6e39502db0c", "public" = "subnet-0bc50953303854350" }
vpc_id = "vpc-0224246255ffa7f6"
```

Note: there is ALSO an older "layer-00/01/02" stack running in the same account with VPC CIDR `10.0.0.0/16`. The rework stack uses `10.10.0.0/16`. Don't confuse the two. We only care about the **rework** stack instances above.

## What already works (do NOT re-test these — confirmed)
1. AWS auth works: `aws sts get-caller-identity` → `753386176131`, `AWS-AutomationEngineering/c5425849`.
2. SSH key fingerprint matches the AWS keypair exactly (`keypair-rework-c5425849`), fingerprint `SHA256:aJZLWCdJGbKUe2Ru/tm8cICTjfoIBr6lhRiMzE2qA4`.
3. **First hop works:** `ssh -i ~/.ssh/id_ed25519 -o IdentitiesOnly=yes ec2-user@3.19.59.179 hostname` returns `ip-10-10-1-173`. So the VPN box is reachable and accepts the key as `ec2-user`.
4. The VPN box's sshd accepts ed25519 (server-sig-algs includes ssh-ed25519). It is NOT a FIPS/key-type problem.
5. Login user discovery: tested `openvpnas`, `openvpn`, `admin`, `ec2-user`, `root` on the VPN box — only `ec2-user` succeeded.

## Earlier dead-ends already ruled out (don't repeat)
- Multiple failures were caused by transposed IP digits (`13.59.59.179`, `13.19.59.179`) — the real VPN public IP is `3.19.59.179`. Always pull IPs fresh from AWS, never type them.
- VPN box was stopped/restarted earlier; it lost its Elastic IP and now has an auto-assigned public IP (`3.19.59.179`) that changes on restart. The rework Terraform was supposed to hold an EIP on it but it's currently detached (Elastic IP column shows `–`).
- Inventory file was previously named `hosts.yaml` while commands used `hosts.yml` — fixed, now `hosts.yml`.

## THE CURRENT FAILURE (this is what to fix)
Running the full jump:
```bash
ssh -i ~/.ssh/id_ed25519 -o IdentitiesOnly=yes \
  -J ec2-user@3.19.59.179 ec2-user@10.10.2.217 hostname
```
First hop into the VPN box succeeds (USG banner shows), then:
```
channel 0: open failed: connect failed: Connection timed out
stdio forwarding failed
Connection closed by UNKNOWN port 65535
```
So: **the VPN box (jump host) cannot open a TCP connection to the private box `10.10.2.217` on port 22.** The second hop times out.

## Most likely root cause (verify, don't assume)
The private box SG `sg-014da667cd62ccec5` probably does not allow inbound SSH from the VPN box. It should allow tcp/22 from either the VPN SG `sg-00abe7e84eceb8f00` or the VPC CIDR `10.10.0.0/16`. A strong suspect: the rule may reference the OLD stack's CIDR `10.0.0.0/16` (which doesn't match the rework private IP `10.10.2.217`), or reference the wrong SG.

## Diagnostics to run (in order) and what each result means

```bash
export AWS_PROFILE=shc-dev-build-l

# A) What does the private box SG allow on port 22?
aws ec2 describe-security-groups --region us-east-2 \
  --group-ids sg-014da667cd62ccec5 \
  --query 'SecurityGroups[0].IpPermissions[?FromPort==`22`]' --output json

# B) Confirm both instances share the same VPC + see the private box's SGs
aws ec2 describe-instances --region us-east-2 \
  --instance-ids i-01640cbe938390708 i-039020ae0cf081a8f \
  --query 'Reservations[].Instances[].[InstanceId,VpcId,PrivateIpAddress,PublicIpAddress,State.Name,[SecurityGroups[].GroupId]]' \
  --output json

# C) Definitive reachability test FROM the VPN box to the private box's port 22
VPN_IP=$(aws ec2 describe-instances --region us-east-2 --instance-ids i-039020ae0cf081a8f \
  --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
ssh -i ~/.ssh/id_ed25519 -o IdentitiesOnly=yes ec2-user@${VPN_IP} \
  'timeout 5 bash -c "cat < /dev/null > /dev/tcp/10.10.2.217/22" && echo OPEN || echo BLOCKED'
```

Interpretation:
- Test C `BLOCKED` + Test A shows no matching source → **SG problem**, this is the fix.
- Test C `OPEN` → port is reachable; problem would be key/user on the private box instead (unlikely, it's stock RHEL with the same keypair).
- Test B shows different `VpcId` between the two instances → they're in different VPCs, jump can't work.

## The fix (if it's the SG, which is expected)
Add inbound SSH on the private box SG from the VPN SG (preferred — source is the SG, not a CIDR):
```bash
aws ec2 authorize-security-group-ingress --region us-east-2 \
  --group-id sg-014da667cd62ccec5 \
  --protocol tcp --port 22 --source-group sg-00abe7e84eceb8f00
```
If that rule already exists but references the wrong thing, or you prefer CIDR-based, alternatively allow the VPC CIDR:
```bash
aws ec2 authorize-security-group-ingress --region us-east-2 \
  --group-id sg-014da667cd62ccec5 \
  --protocol tcp --port 22 --cidr 10.10.0.0/16
```
NOTE: doing this via CLI creates Terraform drift vs `~/training/terraform/rework`. Preferred long-term fix is to correct the private SG's ingress rule in the rework Terraform (`securitygroups.tf`) to allow tcp/22 from the VPN SG or `10.10.0.0/16`, then `terraform apply`. For now, unblocking via CLI is acceptable for training; note the drift.

## Verify the fix
```bash
VPN_IP=$(aws ec2 describe-instances --region us-east-2 --instance-ids i-039020ae0cf081a8f \
  --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
PRIV_IP=$(aws ec2 describe-instances --region us-east-2 --instance-ids i-01640cbe938390708 \
  --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)

ssh -i ~/.ssh/id_ed25519 -o IdentitiesOnly=yes \
  -J ec2-user@${VPN_IP} ec2-user@${PRIV_IP} hostname     # expect the private box hostname

cd ~/training/ansible-bastion
ansible-inventory -i inventory/hosts.yml --graph          # expect @bastion -> bastion-private
ansible bastion -m ping                                    # expect pong
```

## Current inventory file (`~/training/ansible-bastion/inventory/hosts.yml`)
IPs must be filled fresh from AWS each session (VPN public IP changes on restart because the EIP is detached). Current values: VPN `3.19.59.179`, PRIVATE `10.10.2.217`. The ProxyCommand uses `ec2-user@` for the jump host and `-o IdentitiesOnly=yes`:
```yaml
all:
  hosts:
    localhost:
      ansible_connection: local
      ansible_python_interpreter: "{{ ansible_playbook_python }}"
  children:
    bastion:
      hosts:
        bastion-private:
          ansible_host: 10.10.2.217
  vars:
    ansible_user: ec2-user
    ansible_ssh_private_key_file: ~/.ssh/id_ed25519
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o ProxyCommand="ssh -W %h:%p -q -i ~/.ssh/id_ed25519 -o StrictHostKeyChecking=no -o IdentitiesOnly=yes ec2-user@3.19.59.179"'
```

## After connectivity is green — the actual task
Run the bastion playbook: `cd ~/training/ansible-bastion && ansible-playbook bastion.yml`. Watch for a likely next issue: the `repository-management` role on stock RHEL. It's configured with `repo_cdn_override: cdn2` and `repo_connectivity_check: false` so it shouldn't hard-fail, but if it errors on unreachable repo endpoints, that's expected (the box has no GlobalProtect VPN) and can be worked around.

## Constraints
- Do NOT rebuild or swap either instance's AMI. The image is not the problem; connectivity is.
- Do NOT destroy any infra (Patryk's cost directive — stop/terminate only when all tickets done).
- Keep the golden OpenVPN AMI on the VPN box (needed for ticket 7954).
- Always pull IPs fresh from AWS; never hand-type them (digit-transposition has burned us repeatedly).

---

