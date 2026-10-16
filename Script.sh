APPROVED to implement Option C on branch c5425849-sles16 (roles repo). The
verification proved it against our CDN2 RPMs and build #11. Implement exactly as
scoped below — nothing wider.

THE CHANGE (Option C — existence-guard, minimal):
- In base/tasks/sudoers.yml, the two tasks that edit /etc/sudoers directly (the
  secure_path lineinfile at ~line 44, and task 3 — the other direct /etc/sudoers edit):
  add a guard so they RUN only when /etc/sudoers exists, and SKIP when it's absent.
- Use a stat of /etc/sudoers + `when: <stat>.stat.exists` on those two tasks. Register
  the stat once, reuse it.
- Do NOT touch the sudoers.d drop-in task (01-secure-path) — it already delivers
  secure_path on 16 and must keep running on every OS.

HARD CONSTRAINTS — do NOT:
- create /etc/sudoers on 16 (create: true) — proven dangerous: a present /etc/sudoers
  shadows the vendor /usr/etc/sudoers and drops the whole vendor ruleset.
- edit, move, or symlink the vendor /usr/etc/sudoers.
- OS-gate with `when: major < 16` — use existence-guard (stat.exists), it's more robust
  and self-adapts. (The verification recommended existence-guard over OS-gate.)
- change any other task in sudoers.yml, or any other OS's behavior.

WHY THIS IS SAFE (must hold true after your change):
- RHEL / Ubuntu / SLES 15: /etc/sudoers exists → stat.exists is true → both edits run
  EXACTLY as today. Zero behavior change.
- SLES 16: /etc/sudoers absent → both edits skip → secure_path still delivered by the
  sudoers.d drop-in (vendor file has @includedir /etc/sudoers.d, proven read on build #11).

VALIDATE:
- Re-run the aws-com build. Expected: base-configure's sudoers task no longer fails on
  16; the play advances past ok=125. Report where it gets to.
- If it stops later at a patch/zypper-update/STIG step → that's the known Updates/16.0
  mirror gap (Steve's), NOT this change. Distinguish clearly in your report.

STILL HELD (unchanged):
- NO MR, no merge — all SLES 16 MRs held per John.
- Branch c5425849-sles16 only; never main.
- Never edit an InSpec test/check to pass a build.
- Roles repo is CODEOWNED (Gabriel + Jean-Paul) — keep the diff to just the two guards.

REPORT: the exact diff (should be a stat + two `when:` clauses, nothing else), and
where the build gets to with the stop cause named precisely. Then hold.
