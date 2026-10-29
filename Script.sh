Option (a) — update 2.9-000139 in place. Quick guard first: confirm that entry was 
introduced by this branch and isn't already on main/released (git blame or check against 
main). It should be unreleased — Fabric Manager is new in this ticket, so that line can't 
predate this work. If for any reason it IS already on main, stop and tell me instead of 
editing released history.

Assuming it's unreleased: don't add a new changelog version and don't leave it as-is — 
this is all one unmerged MR, so the entry should describe its final shipping state. Update 
it to read along these lines, matching the file's existing style/format:

"Add NVIDIA Fabric Manager and libnvidia-nscq, and pin the NVIDIA driver triplet to 
580.178.04 (R580 LTSB; moving off 535 as it nears EOL)."

Then proceed with step 6: commit to c5425849-nvidia with your proposed message 
(STOI-14396: bump NVIDIA driver 535.309.01 -> 580.178.04 (lifecycle, R580 LTSB)) including 
the changelog edit, and kick validation builds on both 22.04 and 24.04. Report against the 
step-7 checklist, flagging any deviation plainly.
