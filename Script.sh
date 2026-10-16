SLES 16 (SCSEC-8697), roles branch c5425849-sles16. Two things this session, in order.
Still INVESTIGATION + REBASE only — no code changes to fix the cron gap, no MR, no
merge. Stop for my decision before changing anything.

STEP 1 — REBASE FIRST (main moved):
Steve's MR just merged to main (the SLES 16 repo-sync / CDN2 mirror config). Our branch
c5425849-sles16 was cut from an older main. Before anything else:
- Rebase c5425849-sles16 onto latest main in each repo on the branch (roles repo and
  any others). Resolve conflicts carefully — do NOT drop Steve's changes.
- Report what his merge pulled in, and specifically whether it touched anything near
  our files (base/tasks/*, repository-management role, os/sles-*). Expected: no direct
  overlap (his was repo-sync config), but confirm, don't assume.
- Bonus check: did his merge add Updates/16.0 to the sync? i.e. is
  suse/Updates/SLE-Product-SLES/16.0/... now mirrored on CDN2? If so, the patching gap
  may have closed — flag it.
- Our validated sudoers fix (0fa07c5: stat + two guards) must survive the rebase intact.
  Confirm it's still present and unchanged after.
Report the rebase result BEFORE moving to Step 2. If there's a conflict you can't
cleanly resolve, stop and show me.

STEP 2 — INVESTIGATE the cron gap (read-only, recommend, do NOT implement):
Build #13 now fails at: base: "Create and copy hourly logrotate crontab" →
/etc/cron.hourly does not exist (base/tasks/log/main.yml). SLES 16 minimal ships no
cron by default. This is DIFFERENT from sudoers — here, skipping might hide a real
functional gap, so the question is install-vs-guard, not auto-guard.

PRIMARY QUESTION — how does SLES 15 (SP6/SP7) satisfy this today, and does the golden
image NEED cron?
- On a built SLES 15 golden image: is cron/cronie installed? What installs it — is it
  in base_os_package_list, a module, a dependency? Is /etc/cron.hourly present, and does
  the image actually use it (what's in cron.hourly/daily — logrotate, scans, housekeeping)?
- What does THIS task (and anything downstream) actually schedule via cron? If logrotate,
  compliance/STIG scans, or any security housekeeping runs via cron.hourly/daily, then
  cron is FUNCTIONALLY REQUIRED on the image — skipping the task would silently drop it.
- Check the SLES 16 Pool repo: is cron/cronie available to install? (package name on 16 —
  cronie? cron? confirm it resolves against the live Pool content.)

THEN RECOMMEND (do not implement) — two clean options, ranked:
- Option INSTALL: add cron/cronie to SLES 16's base_os_package_list in os/sles-16.yml
  (isolated, safe — our file). Then /etc/cron.hourly exists and the task succeeds
  naturally, matching how 15 behaves. Preferred IF the image needs scheduled jobs.
- Option GUARD: existence-guard the crontab task (skip when /etc/cron.hourly absent).
  ONLY correct if cron is genuinely not needed on these images and nothing downstream
  depends on it — confirm that before recommending it.
- State which is right based on what the image actually needs, and what each affects.
  Bias toward matching SLES 15's real behavior, not just making the task pass.

HARD RULES: branch c5425849-sles16 only; never main; never edit an InSpec test/check;
roles repo CODEOWNED (Gabriel + Jean-Paul) — minimal, 16-scoped diffs; OpenStack by
resource ID. No cron change until I approve. No MR (held per John).

REPORT: (1) rebase result + whether Steve's merge touched our area / added Updates/16.0 +
confirmation our sudoers fix survived; (2) how SLES 15 handles cron, whether the image
needs it, and your ranked install-vs-guard recommendation with reasoning. Then hold.
