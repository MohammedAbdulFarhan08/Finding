Continue SLES 16 (SCSEC-8697) on the roles-repo branch c5425849-sles16. The
repository-management fix is validated (build #10). Next gap: base-configure fails
with "Could not find or access 'os/sles-16.yml'". Author the base-role OS files, then
validate. Same gates as before — no MR, nothing on main.

TASK 1 — author the base-role OS files (mirror SLES 15, adjust only real 16 diffs):
- base-configure does include_vars/include_tasks os/<distro>-<major>.yml per OS; only
  base/vars/os/sles-15.yml + base/tasks/os/sles-16.yml's 15 equivalent exist. Create:
    • base/vars/os/sles-16.yml
    • base/tasks/os/sles-16.yml
- Read the sles-15 versions first and mirror their structure exactly. The vars file
  defines at least base_os_package_list, base_sudoers_path,
  base_logrotate_postrotate_rsyslog — carry those over.
- Change ONLY what SLES 16 genuinely differs on, and for each change, show me WHY
  (don't blindly copy, don't speculatively change). Known candidates to check:
    • logrotate: SLES 16 minimal lacks /etc/logrotate.conf (that's the report.sh
      "cannot stat" warning from earlier) — confirm whether logrotate is present/needed
      and set base_logrotate_postrotate_rsyslog / the package list accordingly.
    • package names: verify every package in base_os_package_list actually exists in
      the SLES 16 repos (16 consolidated modules — some 15 package names may differ or
      be absent). Flag any that don't resolve.
- Keep it minimal and SLES-16-gated; do not touch the sles-15 files or any other OS.

TASK 2 — regression proof (still open from last round, do it now):
- Render the SLES 15 SP5/SP6/SP7 .repo output with the repository-management role
  BEFORE and AFTER your de-hardcode and confirm byte-identical. This proves zero blast
  radius on the shared role for the CODEOWNED review. Report the diff (expect: none).

TASK 3 — validate:
- Re-run the aws-com build. Expected outcome: base-configure now passes os/sles-16.yml
  and the build advances further. Report where it gets to.
- Realistic stop point: the image can provision from Pool, but Updates/16.0 isn't
  mirrored yet — so if it later hits a patch/zypper-update/STIG step with nothing to
  pull, that's the known mirror gap (Steve's), NOT a bug in your files. Distinguish the
  two in your report: "failed because my file is wrong" vs "failed at patching because
  Updates/16.0 isn't on CDN2."

HARD RULES: branch c5425849-sles16 only; never main; never edit an InSpec test/check;
roles repo is CODEOWNED (Gabriel + Jean-Paul) so keep the diff minimal and 16-scoped;
OpenStack by resource ID. Do NOT open any MR — all SLES 16 MRs held per John.

REPORT: the two new files with rationale for every deviation from sles-15, the SLES-15
regression diff result, and where the build gets to (naming the stop cause precisely).
Then hold.
