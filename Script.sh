RHEL 10.2 Base ARM (aarch64), aws_commercial only — investigate-first, change nothing yet, report back. Working tree ~/c5425849-rhel-arm (branch c5425849-rhel-arm, fresh from main). This is SCSEC-8913’s first image; Base-first discipline like we did on Ubuntu — RHEL 10.2 Base, aws_commercial only, do NOT fan out to HANA/SAPAPP or other clouds.

First, study the Ubuntu 24 ARM work as a reference for the approach — look at branch c5425849-ubuntu24-arm and the metal branch c5425849-arm-metal. Understand how each class of ARM problem was solved there: the arch-conditional grub-efi package split, the repository sources arch routing, the agent download-URL arch conditionals (aws-ssm/cloudwatch), and the nessus-agent package-name arch fix. Learn the pattern and where each fix lives — but do NOT cherry-pick or copy Ubuntu code. RHEL is a different OS family (dnf/yum, different repos, different grub packages); every fix needs its RHEL equivalent, found fresh.

Then investigate what RHEL 10.2 needs for aarch64 and report — fixes scoped to aarch64, amd64 byte-identical:

Image-list row: is there a RHEL-10.2 Base row for aws_commercial? Does it have aarch64 in architecture and create_image handling? What needs adding (mirror the dedicated-ARM-row approach from Ubuntu Base).
Repos: how does repository-management build RHEL/dnf repo URLs, and is there a RHEL arm64 arch-routing issue like Ubuntu’s default→default-ports? Probe whether RHEL 10.2 aarch64 CDN2 content actually resolves (BaseOS/AppStream arm64) — the Ubuntu equivalent was the 403/ports-tree problem. Report what the RHEL arm64 repo paths look like and whether they’re reachable.
Grub/EFI: RHEL’s arm64 grub is grub2-efi-aa64 / shim-aa64 (not Ubuntu’s grub-efi-arm64). Find where base installs grub-efi packages for RHEL and what the aarch64 equivalent needs.
Agents: audit the RHEL path for amd64/x86-hardcoded agent packages/URLs (same class as the Ubuntu aws-ssm/cloudwatch fixes) — ssm, cloudwatch, nessus, anything arch-pinned.
Nessus: the role pulls nessus per-OS; RHEL uses an rpm (el8/el9, aarch64), a different artifact than the Ubuntu deb. Report the exact RHEL arm64 nessus filename the role would request so I can get it uploaded (separate from the Ubuntu deb already pending).
Packer: John said RHEL ISO-install for Packer was already done — confirm the RHEL aarch64 pkrvars/template path exists and what, if anything, is missing for a metal/commercial aarch64 RHEL build.

Then STOP and show me: a per-item report of what RHEL 10.2 ARM needs (reusing the Ubuntu pattern, RHEL-specific code), the RHEL arm64 nessus rpm filename, and a proposed change plan. Do NOT edit, commit, run pt, or trigger — I review the plan first.
