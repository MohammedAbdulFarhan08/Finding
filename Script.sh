SLES 16 (SCSEC-8697), branch c5425849-sles16. clamav validated (build 16.1, ok=258).
New gap: base: "Ensure ifcfg-eth0 exists for SLES" → /etc/sysconfig/network does not
exist (base/tasks/networking.yml:24). It writes a wicked-style ifcfg gated on
ansible_os_family == 'Suse'; SLES 16 is NetworkManager-only (wicked removed), so the
dir and the ifcfg are obsolete on 16.

This is a SHARED base task AND it's networking — so verify BEFORE guarding. INVESTIGATION
FIRST, then hold for my approval before any change. No commit, no push.

VERIFY (the stakes are network connectivity — be certain skipping is safe):
- Confirm SLES 16 eth0 gets DHCP with NO wicked ifcfg — i.e. the Agama NM DHCP keyfile
  (ipv4.method=auto) is what brings eth0 up, and it persists to the FINAL image's first
  boot, not just during build. Show the evidence (the NM keyfile present on the built
  image, eth0 up via NM).
- Confirm nothing downstream in the build or the image depends on /etc/sysconfig/network
  or the ifcfg-eth0 file existing (grep the roles for references).
- Confirm SLES 15 DOES have /etc/sysconfig/network + uses wicked (so the guard leaves 15
  untouched).

THEN RECOMMEND (don't implement): existence-guard the task on /etc/sysconfig/network
(skip when absent) — the self-adapting variant, consistent with the sudoers fix. NOT the
major<16 version guard. State blast radius: 15/RHEL/Ubuntu unchanged (dir exists → runs as
today), 16 skips the obsolete wicked write and relies on NM.

If verification shows ANY risk that eth0 loses DHCP on 16 by skipping → STOP and show me;
do not guard.

Also still open: cron service enabled/active on the built 16 image — verify this run if you
can reach a finalized image; else leave flagged, don't add an enable task without asking.

HARD STOP unchanged: DISA/STIG role → do not author, capture + report (call with Steve + Ram).
HARD RULES: branch only; never main; never edit InSpec; CODEOWNED roles repo — minimal
16-scoped diff; OpenStack by ID. MR held.

REPORT: the eth0-DHCP-survives-without-ifcfg evidence, the downstream-dependency check, the
recommended existence-guard, and the cron service state if reachable. Then hold.
