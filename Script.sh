Continue SLES 16 (SCSEC-8697), roles branch c5425849-sles16. Two actions up front, then
a GATED cron decision, then build. No MR, no merge.

1) PUSH: force-push the rebased infrastructure branch to origin with --force-with-lease
   (my own branch, safe). Local and remote must match before the build.

2) VERIFY CRON NEED ON THE REAL SLES 15 IMAGE (read-only) — do this BEFORE adding cron.
   I don't want to install on install-pattern reasoning; prove it like we did for sudoers.
   On a BUILT SLES 15 (SP6/SP7) golden image — our pipeline's image, not SUSE defaults:
   - Is the cron daemon (cronie) actually installed AND the service enabled + running?
   - Is /etc/cron.hourly/logrotate actually present and firing (i.e. logrotate really
     runs via cron on 15, not via a systemd timer or some other mechanism)?
   - Confirm what else on 15 schedules via cron (aide --check, audit STIG watches on
     /etc/cron.d + /var/spool/cron, control SLES-15-030130) is genuinely cron-driven on
     the built image.
   REPORT this first. Interpretation:
   - If SLES 15's built image uses cron for logrotate/aide/STIG → installing cron on 16
     is RESTORING parity, not adding capability. Proceed to step 3.
   - If SLES 15 does NOT actually use cron for these (e.g. systemd timers instead) → STOP
     and show me; the decision changes and I'll re-evaluate.

3) INSTALL CRON (only if step 2 confirms SLES 15 relies on it):
   - Add `cron` to base_os_package_list in base/vars/os/sles-16.yml only (pulls in cronie).
   - Keep the diff to that one package line. Do not touch sles-15 or any other OS file.

BEFORE TRIGGERING THE BUILD:
   - Force-check the roles git resource (fly check-resource) and confirm it picked up the
     NEW commit before triggering — don't run stale code (build #12 lesson).
   - Vault was down over the weekend (Oct 17-18). If a prior build failed, confirm it was
     a real task failure, not a Vault/secrets error, before trusting the result.

VALIDATE (aws-com):
   - Expected: the hourly logrotate crontab task now passes; play advances past ok=152.
   - Confirm cron is actually RUNNING on the 16 image, not just installed: cron service
     enabled + active, and /etc/cron.hourly/logrotate present. If the service isn't
     enabled, flag it — do NOT fix without asking.

HARD STOP AT HARDENING:
   - When the build reaches the hardening/STIG step and breaks (e.g. a missing SLES 16
     DISA/STIG role), do NOT create or modify any STIG/hardening role. Capture the exact
     failure, stop, and report. Steve wants a call with me and Ram to plan that piece.

HARD RULES: branch c5425849-sles16 only; never main; never edit an InSpec test/check;
roles repo CODEOWNED (Gabriel + Jean-Paul) — minimal 16-scoped diff; OpenStack by
resource ID. MR held (John).

REPORT: push result; the SLES 15 cron verification (with evidence); the one-line cron
diff IF you proceeded; the cron service state on the built 16 image; and where the build
stops (name the cause — my change / a new minimal-install gap / hardening / Updates/16.0).
Then hold.
