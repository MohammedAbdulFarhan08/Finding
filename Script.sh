SLES 16 (SCSEC-8697), branch c5425849-sles16. Two things, both read-only / no new
feature code. We're waiting on Steve (collectd → PackageHub on the repo-sync, his side)
and the STIG planning call, so this is "map the remaining path + get MR-ready," NOT
finish. Do NOT author the STIG role, do NOT work around collectd, do NOT open any MR.

1) MAP THE REMAINING GAPS — READ-ONLY (no build, no collectd skip):
   The build currently stops at aws-cloudwatch-agent (collectd, Steve's). I want to know
   the FULL remaining user-owned path before PackageHub lands, instead of discovering it
   one build at a time.
   - From the harden/build playbook ordering, list every role/task that runs AFTER
     aws-cloudwatch-agent and BEFORE the disa-stig (hardening) role.
   - For each of those roles, check read-only whether it has SLES 16 support — i.e. does
     it need a sles/16.0.yml vars file (like clamav-nextgen did), or make SLES-15/
     minimal-install assumptions (a package/path/service that 16 minimal drops, like
     cron/sudoers/logrotate)? Flag each likely gap.
   - Classify each: user-owned (missing vars / minimal-install gap, same pattern as the
     ones I've already fixed) vs the disa-stig hard stop vs Steve's mirror side.
   - Goal: a short list of "here are the N remaining gaps that are mine, in order, up to
     the STIG role." Do NOT fix them yet — just map them.

2) BRANCH STATE SUMMARY (for the MR when the hold lifts + for the STIG call):
   - List every file changed on c5425849-sles16 vs main, grouped (packer / image-lists /
     base-role os files / sudoers / cron / clamav / networking), with a one-line what+why
     each, and which build validated it.
   - Confirm the branch is clean: everything committed + pushed, nothing half-finished,
     and re-confirm SP7/InSpec/main/Vault/pre-release-Vault all still untouched.
   - Note any throwaway/experimental commits from the build churn (#6–#17) that should be
     squashed before John sees the history — but do NOT squash or open the MR yet.

3) STILL OPEN — note, don't fix:
   - Collectd: Steve's (PackageHub via repo-sync). Build stays stopped there until it
     syncs to CDN2. Not ours.
   - Cron service enabled/active on the built image: still unverifiable (no build
     finalizes an image — the STIG-role gap blocks finalization). Leave flagged.
   - disa-stig role: the hard stop. Steve + Ram + me plan it on a call.

HARD RULES: branch only; never main; never edit InSpec; CODEOWNED roles repo; OpenStack
by ID. No MR, no STIG role, no collectd workaround.

REPORT: the ordered list of remaining user-owned gaps up to the STIG role, the grouped
branch changelist, and the squash candidates. Then hold.
