The ARM repo-sync is confirmed green — go ahead and run the first ARM build. Ubuntu 24.04 Base, aws_commercial only, exactly as staged on c5425849-ubuntu24-arm. This is a real build, work carefully.

Quick pre-flight (you already verified most of this — just reconfirm):

pt is updated to the aarch64-aware build (pt-go v0.1.7+) — check the version before running.
The aws-commercial ARM Vault path is in place (I added it).
The ARM row is still scoped: architecture: [aarch64], cloud_partition: [aws_commercial], Base only, enable_fips: true, t4g.2xlarge — no other Ubuntu-24 row has aarch64.

Build:

Flip create_image → true on the aws-commercial Base ARM row.
Run: pt --clouds=aws-com --code-prefix=~/main --arm
Stay on the branch — no push, no MR yet.

Watch end-to-end and report at each stage:

ISO install — native KVM now, should be normal speed, not the emulated hour.
repository-management — this was the exact failure point before and the thing the sync just fixed; watch it specifically.
FIPS on aarch64 — confirm the arm64 FIPS mirror resolves cleanly.
InSpec/scan result.
If it fails anywhere, capture the stage + exact error and STOP — no blind retry.
If green: confirm the image name rendered Golden-ARM-CDN2-SCS-Ubuntu-24.04-Base.

Hold for my go on anything past the build — boot-test VM, MR, further Vault. Report the build result first.
