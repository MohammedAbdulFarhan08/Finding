Context: STOI-14396, in ~/c5425849-nvidia. Before raising the MRs I want both branches 
rebased onto latest main. Do NOT force-push and do NOT raise any MR until I approve — stop 
and show me first.

1. Fetch latest main, then rebase both branches onto it: roles (c5425849-nvidia) and inspec 
   (stoi-14396-nvidia-fm-scan-exclusion).
2. Expect a conflict in CHANGELOG-SCS.md (main likely added entries) — resolve by KEEPING 
   BOTH main's new entries AND our FM/580 entry, drop neither. Any OTHER conflict, or 
   anything touching nvidia.yml or the build config — STOP and show me, don't guess.
3. While rebasing: confirm test_c5425849_build.yml points at main (strip any fix-branch 
   pointer), and squash the roles branch to ONE commit: "STOI-14396: add NVIDIA Fabric 
   Manager + bump driver 535.309.01 -> 580.178.04 (lifecycle, R580 LTSB)". Leave the inspec 
   branch as its single commit.
4. STOP and report: the rebased diff per branch, how you resolved the changelog, the final 
   commit(s), and whether the rebase pulled in anything beyond the changelog (esp. nvidia 
   path or build config).

On my go-ahead you'll force-push and raise the two MRs, inspec first then roles.
