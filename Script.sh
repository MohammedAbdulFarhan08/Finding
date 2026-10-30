Context: SCSEC-8697, SLES 16 enablement. Build #25 cleared the reboot and the branches were 
held pending that — now I want roles, playbooks, and infra rebased onto latest main. Packer 
is already rebased, leave it. Do NOT force-push and do NOT raise/merge anything — stop and 
show me first.

1. Fetch latest main, then rebase these three branches onto it: roles, playbooks, infra.

2. Known conflict-prone spots from earlier analysis — resolve carefully, don't guess:
   - harden.yml (hardening changes land here often)
   - the ssh-hardening drop-in rename (main's 99- -> 10-scs-hardening.conf — #25 already 
     confirmed this; make sure the rebase keeps main's 10- naming, not our old 99-)
   - any CHANGELOG conflict -> keep BOTH main's entries and ours, drop neither
   For ANY conflict beyond these, or anything touching the SLES 16 files (os/sles-16.yml, 
   the fips/tasks/sles/16 paths, sles16.yml vars), STOP and show me rather than resolving 
   blind.

3. Report per branch: the rebased diff, every conflict and how you resolved it, and — this 
   is the important one — whether the rebase pulled in anything from main that touches the 
   SLES 16 build chain (base config, FIPS, hardening, or the InSpec expectations). Flag that 
   explicitly.

4. STOP there. On my go-ahead I'll have you force-push and kick a fresh validation build to 
   re-confirm the full chain on the rebased branches.
