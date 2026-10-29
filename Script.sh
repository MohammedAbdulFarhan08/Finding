Context: STOI-14396, NVIDIA Fabric Manager fix. Final verification before I raise the MRs.

Your earlier read-only report concluded the gov pin is satisfiable by inference (single 
CDN2 mirror, no gov override, driver already green on gov). That reasoning is sound, but 
it was run from a commercial network — the gov S3-website bucket returned 404 from there. 
I want to close the one remaining gap by observing the gov mirror's content directly, 
from inside gov.

Do this read-only — NO builds, NO commits, NO pushes, and do NOT modify anything on the 
host. This is a single package-index lookup.

From a GovCloud build host (find which host/partition actually runs the aws_govcloud 
nvidia builds — don't assume, confirm it from the repo/pipeline config), fetch the Ubuntu 
package index off the CDN2 mirror and confirm the pinned triplet is present at exactly 
535.309.01 for BOTH jammy (22.04) and noble (24.04):

  - nvidia-fabricmanager-535
  - libnvidia-nscq-535
  - nvidia-driver-535-server

Check the -updates and -security pockets (multiverse for FM + nscq, restricted for the 
driver), matching how the report found them on the commercial edge. The report named the 
shape of the lookup already (curl the Packages.gz for the right dist/pocket/arch, zgrep 
the package names) — use that as the starting point but verify the dist/pocket/arch paths 
against the repo rather than taking them on faith.

Report back: which gov host you ran from and how you confirmed it's the right one, the 
exact URL(s) you fetched, and the exact version string that resolves for each of the three 
packages on each OS. State plainly whether every one matches the 535.309.01 pin, or flag 
any that doesn't resolve or resolves at a different build string. Don't fix anything — 
just give me the evidence.
