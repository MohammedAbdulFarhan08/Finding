Approving Phase 1 — proceed to Phase 2. The converter diff settled the profile
question and the three decisions are locked. Stop at the two gates I mark.

DECISIONS (confirmed — don't re-ask):
- Scope = MINE FIRST. Add SLES 16 to my own test-c5425849 (CDN2 + CDN1) and both
  pre-release lists only. Do NOT touch the other 7 users' test lists — that's a
  later fan-out, after this is green.
- Naming = DASH. Group key sles-16-0, image name Golden-...-SLES-16-0-cHost,
  operating_system_version '16.0' (dotted, to match the pkrvars filename). No dots
  in the name token.
- Profile = XML-TO-GREEN baseline first. Reuse the proven SP7 AutoYaST XML (served
  from packer http_content) so the boot_command is the ONLY unknown on build #1.
  JSON conversion is a follow-up, not now.

PROFILE / KERNEL ARGS (from your converter diff — important):
- The converter drops the whole bootloader section incl. the kernel append line.
  Two args are load-bearing and MUST be restored for SP7 parity:
  net.ifnames=0 biosdevname=0 (stable eth0 — needed for scan-phase networking) and
  console=ttyS0,115200n8 (the serial log the pipeline reads).
- BEFORE authoring an Agama bootloader section for these, CHECK the base ansible
  role's grub_kernel_opts first — that's where the kvm-clock arg lives. If
  net.ifnames/console already ride the base role across images, the restore shrinks
  or disappears. Report that finding before writing any JSON.
- These are NOT needed for build #1 CREATE (Agama defaults + DHCP get Packer in).
  They're needed for SCAN-green and parity.

DEFINITION OF DONE (hold this line):
- CREATE-green = install completes = proves the boot_command. That is NOT ticket-done.
- SCAN-green + SP7 parity = the real bar, needs the kernel args restored. Do not
  report the ticket done at CREATE-green.

BEFORE YOU BUILD:
- Rebase c5425849-sles16 on latest main (git pull/rebase). The branch was cut from
  main; I don't want a stale-branch surprise.

PHASE 3 VERIFICATION (on the built image, before deciding JSON scope):
- NIC is eth0 (not ens*), serial log present, post.sh sudoers ran, bios-grub.sh ran
  (legacy BIOS). Plus the base-role grub_kernel_opts finding above.

HARD RULES (unchanged):
- Branch c5425849-sles16 only; never commit to main.
- Never edit an InSpec test/check to make a build pass.
- Never modify pre-release Vault secrets (copy from only).
- OpenStack: act by resource ID, not name.
- CDN1 currently has SP5+SP6 but NOT SP7. Adding SLES 16 to CDN1 is additive and
  safe, but it's slightly ahead of the existing pattern — flag it in your plan,
  don't silently mirror SP6.

GO ORDER: packer repo first (pkrvars + profile + the four golden.pkr.hcl
http_content entries + validate-all), then the image-list rows, then build + VNC to
lock the boot_command. Show me the boot_command you derived and build #1's result
before moving on to the kernel-args restore.
