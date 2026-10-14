You're helping me enable SLES 16 as a new OS across the SAP Golden Images project
(Jira SCSEC-8697). I'm going to paste the ticket description and the GitLab URL John
shared in my next message — treat the ticket as the source of truth for scope (which
image-lists, which variants, create_image settings) and let me know if anything in it
contradicts the notes below.

WORKFLOW RULE (most important): Work in two gated phases. Phase 1 is read-only
investigation — you analyze, assess risk and blast radius, and propose a plan, then
STOP and wait for my explicit approval. Do NOT edit, create, or commit any file until
I approve. After approval you implement. Never touch main; everything lives on the
feature branch.

── Environment (already set up) ──
- Feature tree: ~/c5425849-sles16 (a cp -a of ~/main). The actual repos are nested
  under it at scs/golden-images/<repo> (packer, infrastructure, ansible, playbooks,
  inspec-image-tests).
- Branch c5425849-sles16 is already cut in packer and infrastructure.
- Per-version Packer vars live at scs/golden-images/packer/os_pkrvars/sles/ —
  sles-15.5 / 15.6 / 15.7-x86_64.pkrvars.hcl exist; I need a new
  sles-16.0-x86_64.pkrvars.hcl.
- The SLES 15 install profiles are AutoYaST XML served from Packer's HTTP dir:
  packer/http/sles/sles15-SPx.xml (the boot_command points at them via
  autoyast=http://{{.HTTPIP}}:{{.HTTPPort}}/sles/...).
- John staged the ISO: SLES-16.0-Full-x86_64-GM.install.iso in S3 iso storage and in
  ~/iso on the build servers.
- Build/test: personal pipeline via `pt --clouds=<cloud> --code-prefix=$HOME/c5425849-sles16`;
  monitor with `buildwatch`; watch a hung install over VNC (the `vnc <port> [host]`
  script + TigerVNC — you can read the screenshots). MRs go through the gitlab-mr skill.

── Critical context to VERIFY (don't take on faith — confirm via the web AND the ISO) ──
SLES 16 replaced YaST/AutoYaST with a new installer called Agama. This means the SLES 15
boot_command pattern (edit the GRUB entry, append
`netsetup=dhcp YAST_SKIP_XML_VALIDATION=1 textmode=1 autoyast=...xml`) will NOT transfer.
What I've been told about Agama, to confirm against SUSE's SLES 16 docs and the actual GM ISO:
- Unattended boot uses Agama kernel params, roughly: root=live:<squashfs url> (mandatory),
  inst.auto=<profile url>, live.password=<installer env pw>. Confirm the exact param names
  for THIS GM ISO (there's history around inst.auto vs agama.auto, and some reports of
  inst.auto not being honored — verify empirically).
- Profiles are JSON/Jsonnet, not XML. The existing AutoYaST XML can be converted with
  `agama profile autoyast <url> > profile.json` — check what survives conversion.
- For the HANA/SAPAPP (SLES-for-SAP 16) variants, some profile sections (e.g. NTP /
  access config) are reportedly unsupported — confirm and handle.

── Phase 1 — INVESTIGATE (read-only), then report ──
1. Confirm the Agama facts above via SUSE's SLES 16 documentation.
2. Get the ISO checksum: `shasum -a 256` on the staged SLES-16.0 ISO (on a build server
   if not local), and confirm the exact iso_url path the packer repo expects.
3. Loopback-mount the SLES 16 ISO and read its boot loader config (grub.cfg / EFI loader
   entries) to derive the REAL boot menu structure and default kernel line — so the
   boot_command keystrokes come from the actual menu, not guesswork.
4. Read the current SLES 15 AutoYaST profile (packer/http/sles/sles15-SP7.xml) and the
   packer template that consumes os_pkrvars (golden.pkr.hcl) so you understand how the
   pkrvars fields and the profile flow into a build.
5. Locate the SLES 15 rows in BOTH the testing and the pre-release image-lists; note the
   variants and create_image settings I'll need to mirror for SLES 16.
6. Then give me: (a) your findings, (b) a RISK + BLAST-RADIUS analysis — what this change
   can and cannot affect across the full OS/cloud/variant matrix, and confirmation that a
   new sles-16.0 pkrvars file + new image-list rows can't disturb existing OSes, and
   (c) a concrete, ordered implementation plan. Then STOP for my approval.

── Phase 2 — IMPLEMENT (only after I approve) ──
Create sles-16.0-x86_64.pkrvars.hcl (ISO name, version strings, checksum, and the
Agama-shaped boot_command), add the install profile (converted or authored), and add the
SLES 16 rows to both image-lists — all on branch c5425849-sles16.

── Phase 3 — BUILD & VERIFY ──
Build SLES 16 in my personal pipeline, watch with buildwatch, VNC in if the install hangs,
read the installer screen, fix the boot inputs, iterate until the variants build and scan green.

── Phase 4 — MR ──
When it's green, draft the MR(s) via the gitlab-mr skill for my review.

── Hard rules ──
- No writes of any kind until I approve the Phase 1 plan.
- Branch c5425849-sles16 only; never commit to main.
- Never modify the pre-release Vault secrets (copy from them only).
- Never edit an InSpec test or any check just to make a build pass.
- In OpenStack, always act by resource ID (names aren't unique).
- If the ticket scope differs from these notes, flag it and ask before proceeding.
