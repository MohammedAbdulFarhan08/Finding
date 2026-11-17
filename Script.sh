Proceed with the bare-metal ARM Ubuntu 24 prep on the tree ~/c5425849-arm-metal (branch c5425849-arm-metal), staging only — do NOT run pt, do NOT trigger, stop before any build.

Flip create_image to true on the Ubuntu-24.04-QEMU aws_metal row.
Create branch c5425849-arm-metal on BOTH the roles and infrastructure repos, and cherry-pick the 5 Base-ARM commits that aren’t in main (grub-efi arm64, the default→default-ports sources reroute, the aws-ssm-agent + aws-cloudwatch-agent URL arch-conditionals, and the nessus-agent role package-name fix) — carry their CHANGELOG entries too.
Add the qemu-build-host role aarch64 fixes you identified (the install-packer.yml windows-update stat path, and anything else from your audit) — scoped to aarch64, amd64 byte-identical.
Push both branches to origin (they don’t exist there yet — Concourse’s git resource fails without them).
Run full pre-commit + ansible-lint, confirm 0 failures.

Then STOP and show me: the cherry-pick result, the qemu-build-host diff, and confirmation both branches pushed clean. Do NOT run pt or trigger — the build still gates on the nessus arm64 deb landing in the bucket, which is in progress separately. We stage everything now and trigger once the deb’s up and the role name matches.
