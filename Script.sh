SLES 16 (SCSEC-8697), branch c5425849-sles16. Before I approve the sudoers fix, prove
the reasoning against OUR ACTUAL BUILT IMAGES, not package theory. Still INVESTIGATION
ONLY — no edits to sudoers.yml or anything, no commit, no push, no build-to-change.
Read-only verification, then hold.

Your report concluded SLES 15 ships /etc/sudoers via the sudo package and SLES 16 ships
/usr/etc/sudoers instead (stateless split). I need that confirmed on the real images
our pipeline produces, not stated from how SUSE packaging generally works.

VERIFY on a built SLES 15 (SP6 or SP7) golden image — the one our pipeline builds:
- Is /etc/sudoers actually present on the built image at the point base/tasks/sudoers.yml
  runs? Show the evidence (ls -l / rpm -qf /etc/sudoers / which package owns it).
- Is /usr/etc/sudoers absent on 15? Confirm.
- Confirm NO team task/role/profile creates or moves /etc/sudoers on 15 — it's purely
  the sudo package. (If something in our repos does touch it, I need to know.)

VERIFY on a built SLES 16 image (or the SLES 16 sudo package from the live Pool repo):
- /usr/etc/sudoers present, /etc/sudoers genuinely absent on a fresh install? Show it.
- Is the sudoers.d/01-secure-path drop-in actually written AND actually read by sudo on
  16 (i.e. the vendor /usr/etc/sudoers really contains @includedir /etc/sudoers.d)? Prove
  secure_path is delivered via the drop-in independent of the /etc/sudoers edits.
- Confirm /etc/sudoers is not a symlink/CoW to /usr/etc on 16 — genuinely not there.

If ALL of that holds, the Option C reasoning (existence-guard the two /etc/sudoers edits
with when: <stat>.stat.exists so 15/RHEL/Ubuntu run exactly as today and 16 skips the
redundant edits) is proven. If ANYTHING differs from your earlier report, flag it — it
changes the fix.

HARD RULE: do not implement Option C or any sudoers change yet. I need the verification
evidence AND a team sign-off first. Report the proof for each point above, then hold.
