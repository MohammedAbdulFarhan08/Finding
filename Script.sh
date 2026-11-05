New workstream, SCSEC-8912 — Ubuntu 24.04 ARM (aarch64) enablement. Set up a ticket tree + branch off main per our standard workflow (slug ubuntu24-arm). Investigate and draft on the branch — do NOT commit, push, or MR until I approve. A real ARM build also depends on John’s pipeline (below), so the actual build waits for my go too.

First thing — check the dependency. This sits under the new ARM epic SCSEC-8909. John owns SCSEC-8910, “pipeline to build ARM images by architecture” (was In Progress, he hoped to finish ~today). Confirm whether that groundwork is merged to main / actually available yet. If yes, we can build after I review. If not, we do the full investigation + draft the enablement changes now and hold the build until John’s piece lands. Tell me which it is before anything else.

Context. ARM epic is NS-2-driven for cost (~40% cheaper on Graviton). Three OS stories are mine — SLES SP7 (8911), Ubuntu 24 (8912), RHEL 10.2 (8913) — doing Ubuntu 24 first. Steve has already synced the ARM packages and staged the ARM ISOs on the repo server. John’s pipeline builds by OS across AWS/Azure with little per-cloud work.

Scope — phased, AWS first (Steve’s call). Target aws_commercial first; that’s biggest and where Graviton lives, and NS-2’s request is AWS (+ GCP, maybe Azure). But GCP and OpenStack don’t offer ARM instances, so they’re OUT of scope — do NOT add gcp/openstack ARM rows. Azure ARM is possible as a later phase, not now.

Investigate first — map the x86 baseline, then the ARM delta:

How Ubuntu 24.04 x86_64 is built today end-to-end: the image-list rows in test_c5425849-image-list.yml, packer/os_pkrvars/ubuntu/, the base-role path, and everywhere arch is implicitly amd64/x86_64 (packer vars, ISO name, instance type, repo arch, grub, any uname/arch assumptions). List every arch-hardcoded spot.
What SCSEC-8910 actually gives for “build by architecture” — how the pipeline selects/parameterizes arch, and which image-list/packer field drives aarch64 vs x86_64. Find the real mechanism before writing anything; don’t assume whether the aarch64 build runs via QEMU emulation or a native ARM build host — that’s John’s pipeline’s decision.
Confirm Steve’s synced ARM content is in place: the Ubuntu 24.04 aarch64 ISO where packer expects it, and the aarch64 package repos on our mirror — same mirror-only rule as always, the build must resolve with no outside reach.

Then propose the change set (don’t apply yet): a new aarch64 Ubuntu 24 packer os_pkrvars mirroring the x86_64 one (arch-swapped), image-list row(s) for the ARM variant on aws_commercial with a Graviton temporary_instance_type_override (propose a c7g/m7g/t4g-class type — I’ll confirm), operating_system_distribution: ubuntu / version 24.04, create_image gated, enable_fips to match our standard, a name reflecting arm64, plus any arch-conditional base-role logic. Flag every x86-hardcoded spot you’d touch.

Known gotchas: the InSpec active-initramfs control greps RHEL-style initramfs-* and already false-fails on KVM Ubuntu (initrd.img-*) — watch it doesn’t bite on ARM Ubuntu. azure-cli is not a concern here — Ubuntu is already on the apt/MS-repo path, so the RHEL pip problem we’re fixing elsewhere doesn’t apply to this image. RHEL 10 ARM known-broken (use 10.2) is a different OS, not this ticket.

Deliverable: (1) is John’s pipeline (8910) available yet, (2) the x86→ARM map with every arch-hardcoded spot, (3) the proposed change set + the Graviton instance type, (4) confirmation the ARM ISO + packages resolve from our mirror, (5) open questions for John (arch mechanism) and Steve (mirror ARM content). Then hold for my go.
