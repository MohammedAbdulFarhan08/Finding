Picking up the SLES 16 repository-management role fix (SCSEC-8697). Context below,
then a read + draft task — do NOT build or MR yet. Stop at the gate.

WHAT CHANGED (from Steve, my TL, over Slack):
- Steve confirmed SLES 16.0 is syncing to the CDN2 mirror and pointed me at the S3
  bucket: us-east-2.repositories.images.scs.sap. He said "we just need to update the
  repository-management role to support it."
- I offered to take the role side; he handed it to me. So the role fix is now MY
  work on this ticket. SP7 is NOT mine — reference only.

MRs to read from your side (infrastructure repo, gitlab .../scs/golden-images/infrastructure):
- !444 feat(repo-sync): enable SLES 16.0 mirroring on CDN2 zypper sync — STILL OPEN.
  Adds sles16_0 to release_list + minor_release_versions in
  ansible/repository-synchronization-zypper/sles15.yml, product IDs SLES 2930 /
  SLES_SAP 2985 / sle-ha 2937 / PackageHub 3137. Key notes from the MR: SLES 16
  CONSOLIDATES the modular structure (no separate basesystem/containers/
  server-applications modules — product list intentionally shorter than SP7), and
  it's CDN2-ONLY. Its own testing note says the sync mirrors SLES 16 repos on the
  NEXT RUN AFTER MERGE — so the package repos don't exist on CDN2 until !444 merges
  and the sync runs.
- !443 feat(image-list): enable SLES 15 SP7 for CDN2 production — SP7 counterpart,
  reference only, NOT my work.
- !445 feat(terraform): CDN2 EBS expansion for ARM — unrelated infra, ignore.
Read !444 and !443 (overview + diff) and confirm my understanding above.

TASK 1 — map the mirror reality (read-only):
- In the S3 bucket, check what's actually mirrored for SLES 16 RIGHT NOW. I've seen
  SLE-INSTALLER/16.0/x86_64/product/ (installer medium + repodata). Look specifically
  for the PRODUCT/package repos — SLES, SLES_SAP, sle-ha, PackageHub 16.0 paths —
  not just SLE-INSTALLER. Report whether those product repo paths exist yet with
  repodata, or only the installer path. (If only installer, that confirms !444 hasn't
  synced yet.)
- Capture the real SLES 16 repo-IDs and baseurl paths as they exist/will exist on the
  mirror, so the role points at real paths, not guessed ones.

TASK 2 — diff the role (read-only):
- In the repository-management role (sles-repo.j2 + defaults/main.yml SLES presets),
  diff how SP6 (working) computes its .repo file vs what SLES 16 produces. Pin the
  exact spots where the 15-SP layout is hardcoded (the sles16_sp[0].repo filename,
  the module-name split, the baseurl paths — all shaped for SLES-15's modular layout).
- Given SLES 16 is unified/no-SP, propose the MINIMAL de-hardcode to support a no-SP,
  unified-module version. Show me the exact change and its size.

HARD GATE — STOP HERE:
- Do NOT run a validation build yet. The SLES 16 PRODUCT repos aren't mirrored until
  !444 merges + the sync runs — a build now hits the same "no repositories reachable"
  and tells us nothing. Draft the fix, don't validate it.
- Do NOT open any MR (John's directive: hold all SLES 16 MRs until the release flow
  is going).
- Branching the ROLES repo is new scope — it's shared across all OSes and CODEOWNED
  (Gabriel + Jean-Paul approve). Branch c5425849-sles16 only; never commit to main;
  never edit an InSpec test; OpenStack by resource ID.

REPORT: confirm the MR understanding, the mirror state (product repos present or
installer-only), the exact role de-hardcode with its diff, and tell me the trigger
for when a validation build becomes possible (i.e. product repos visible on CDN2
after !444). Then hold.
