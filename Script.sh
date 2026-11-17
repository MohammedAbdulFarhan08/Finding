SLES SP7 ARM (aarch64), aws_commercial, Base/cHost — investigate-first, change nothing, report back. Working tree ~/c5425849-sles-arm (branch c5425849-sles-arm, fresh from main). This is SCSEC-8911. Confirm the exact SLES version this targets first (ticket says SP7 = SLES 15 SP7, NOT SLES 16 — flag if the image-list says otherwise).

Priority item — derive the nessus filename first and report it immediately: the nessus-agent role pulls a per-OS package from s3://sap-core-images-binaries/packages/tenable/. For SLES aarch64, work out the exact filename the role would request (version pinned in playbooks/nessus-agent.yml, SUSE/SLE suffix, aarch64 token, .rpm). I need this exact string to request the upload — report it before anything else.

Then study the Ubuntu and RHEL ARM work as reference for the approach (branches c5425849-ubuntu24-arm, c5425849-rhel-arm) — learn how each ARM problem class was solved, do NOT copy the code (SLES is a third OS family: zypper, SUSE repos, its own grub/EFI). Then audit what SLES SP7 needs for aarch64 and report, scoped aarch64-only / amd64 byte-identical:

Image-list: is there a SLES SP7 Base/cHost row for aws_commercial, and does it have aarch64 in architecture? (SLES is cHost-only in these lists per prior work.) Base-first discipline — only the Base/cHost ARM row, nothing fanned out.
Repos: how does repository-management build SUSE/zypper repo URLs, and is there a SLES arm64 arch-routing issue? Probe whether SLES SP7 aarch64 CDN2 content resolves live.
Grub/EFI: SLES’s arm64 grub/shim equivalents vs the x86 packages.
Agents: audit the SLES path for amd64-hardcoded agent packages/URLs.
Packer: SP7 aarch64 pkrvars/ISO — note the SP7 aarch64 ISO is already in S3 (SLE-15-SP7-Full-aarch64-GM-Media1.iso); confirm the template/pkrvars path.
FIPS/SELinux/AppArmor and any SLES-specific posture — flag but don’t solve, note which are other-owner.

Then STOP and show me: the nessus filename (up top), the per-item report, and a proposed change plan. Do NOT edit, commit, run pt, or trigger.
