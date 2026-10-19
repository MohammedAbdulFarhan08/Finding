Continue SLES 16 (SCSEC-8697), roles branch c5425849-sles16. Steve confirmed clamav-nextgen
is mine to do; the DISA/STIG role remains the hard stop. Author the clamav-nextgen SLES 16
vars file, validate, then hold. No MR, no merge.

GAP: build #14 fails at clamav-nextgen: "Load version-specific variables for SLES" → missing
clamav-nextgen/vars/sles/16.0.yml (only sles/<15.x>.yml exist).

TASK — author clamav-nextgen/vars/sles/16.0.yml (mirror SLES 15, adjust only real 16 diffs):
- Read the SLES 15 vars file(s) in clamav-nextgen/vars/sles/ first and mirror the structure
  exactly. Create the 16.0.yml by the same pattern os/sles-16.yml followed.
- Change ONLY what SLES 16 genuinely differs on, and for EACH change show me WHY (verified
  against live SLES 16 Pool content / the built image — not package theory). Likely things
  to check:
  • clamav package name(s) on SLES 16 — confirm they exist/resolve in the SLES 16 Pool repo
    (16 consolidated modules; names may differ or live in a different module).
  • any path/service/unit names the vars file references that moved under 16's /usr/etc
    stateless split or the unified module layout.
- Keep it minimal and 16-scoped. Do NOT touch the sles-15 vars, the clamav tasks/logic, or
  any other role.

VALIDATE (aws-com):
- Re-run the build (force-check the roles git resource first, confirm it has my new commit —
  build #12 stale-code lesson). Expected: clamav-nextgen now loads its 16 vars and the play
  advances past ok=206.
- Name precisely where it stops next: my clamav file / a new missing-vars gap in another
  pre-STIG role / the DISA-STIG hard stop / Updates/16.0.

HARD STOP (unchanged): if the build reaches the hardening/DISA-STIG role and breaks, do NOT
create or modify any STIG/hardening role — capture the failure and report. That's the call
with Steve + Ram.

ALSO still open (don't lose it): the cron SERVICE enabled/active state on the built 16 image
is still unverified — if you can reach a finalized image/scan this run, confirm cron is
enabled+active; if not, leave it flagged, do NOT add an enable task without asking.

HARD RULES: branch c5425849-sles16 only; never main; never edit an InSpec test/check; roles
repo CODEOWNED (Gabriel + Jean-Paul) — minimal 16-scoped diff; OpenStack by resource ID.
MR held (John).

REPORT: the 16.0.yml with rationale per deviation, the clamav package-name confirmation
against the Pool, where the build stops next, and the cron-service state if you could reach
it. Then hold.
