Context: STOI-14396 — I've added NVIDIA Fabric Manager to the Ubuntu Gardener-Nvidia 
golden images. The fix (already building green on aws-com) pins a triplet in the base 
role's nvidia install path: nvidia-driver-535-server + nvidia-fabricmanager-535 + 
libnvidia-nscq-535, all at 535.309.01 (the -0ubuntu0.22.04.2 build string on jammy / 
-0ubuntu0.24.04.2 on noble), and enables nvidia-fabricmanager at boot. Working tree is 
~/c5425849-nvidia, branch stoi-14396-nvidia-fabric-manager.

What I need verified, read-only — do NOT trigger any builds, and do NOT commit or push 
anything. This is a package-availability check before I raise the MRs.

The live H200 incident this fixes is on AWS GovCloud, but I've only validated a 
commercial build so far. I need to confirm the GovCloud partition can actually pull all 
three pinned packages at exactly 535.309.01 for BOTH Ubuntu 22.04 (jammy) and 24.04 
(noble) — the driver is presumably fine since these images already build there, but the 
real question is whether fabricmanager-535 and libnvidia-nscq-535 are present on the gov 
mirror at that same pinned version. If the pin isn't satisfiable on gov, the build will 
go red after merge in the exact place I can least afford it, so I want certainty here.

Figure out from the repo how partitions map to their package mirrors / sources, then 
check the pinned triplet resolves on the GovCloud mirror for both OS versions. While 
you're at it, do the same quick availability check for the other partitions these three 
images target so I'm not blindsided elsewhere — commercial, GCP, KVM for 22.04; the 
metal target for 24.04; and the legacy CDN1 mirror for the old CDN1 22.04 image. 

Report back with evidence: which mirror you checked per partition, and the exact versions 
that resolve for each of the three packages. Call out clearly any partition/OS where the 
pin is NOT available, or where a different build string would be resolved than the one 
I pinned. Don't fix anything — just tell me what you find.
