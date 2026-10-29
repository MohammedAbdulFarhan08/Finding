Context: STOI-14396. Goncalo asked us to move the NVIDIA driver 535 -> 580 on the 
Gardener-Nvidia golden images (lifecycle reason: 535 past its support window). The install 
is a SINGLE shared preset (products/nvidia.yml, the `nvidia` preset) used by EVERY 
Gardener-Nvidia image -- 22.04 + 24.04, all partitions (commercial/gov/esc/gcp/kvm/metal). 
So this changes the driver for ALL Gardener-Nvidia consumers, not just the H200 nodes. 
I need blast radius established to zero margin. Read-only: NO builds, commits, or pushes.

Fact to work from -- VERIFY it against an authoritative NVIDIA source, do not trust my 
word or your own training: per NVIDIA's Unix driver deprecation schedule, branch 580 is 
the LAST to support Maxwell/Pascal/Volta -- 580 STILL supports them; the drop is at 590. 
535 already dropped nothing below Maxwell (Kepler ended at 470). So at the architecture 
level 580 should be a SUPERSET of 535. Confirm against NVIDIA's supportedchips list / 
release notes for nvidia-driver-580-server and 535-server. If you can't reach an 
authoritative source, say so -- do NOT assert from memory.

Answer three things, each with evidence:

1. ARCHITECTURE/SKU DELTA (580 vs 535), authoritative and SKU-level: from NVIDIA's 
supportedchips README for 580-server (580.178.04) and 535-server, produce the device/PCI-ID 
set each supports and compute the difference. State plainly: "580.178.04 supports every 
device 535 did -- yes/no," with evidence. Prove it at the SKU level; do not infer from the 
architecture headline.

2. FLEET REALITY: determine from the repo/pipeline/image-lists which instance types / GPU 
SKUs these images are actually deployed on, across all partitions + both OSes (instance-type 
allowlists, node-pool/shoot refs, image-list targets -- anything naming the hardware). Then 
state clearly what CAN and CANNOT be determined from this repo. The per-consumer GPU SKUs 
are likely not fully knowable here -- list exactly what must be confirmed by John / platform 
owners, phrased as precise yes/no questions.

3. NON-ARCHITECTURE RESIDUALS (risks that survive even on a clean superset):
   - Is 580.178.04 a Production/LTSB line or a New Feature Branch? (lifecycle matters for a 
     prod golden image.)
   - CUDA version shipped/required by 580 vs 535, and whether forward-compat covers existing 
     consumer workloads/containers, or whether any consumer pins a driver/CUDA version a 580 
     jump would disturb (search repo; note what must be confirmed with consumers).
   - Fabric Manager + nscq lockstep at 580.178.04 on both OSes (must match the driver 
     exactly -- re-confirm all three resolve at 580.178.04).
   - Does the fix need a SPECIFIC 580 build? Goncalo's original ask (580.196.07) is NOT on 
     the mirror; 580.178.04 is. Confirm whether the H200 rationale is purely lifecycle (any 
     supported 580 suffices -> .178.04 fine) or depends on something landing after .178.04 
     (-> .178.04 insufficient; flag it).

Also surface, without treating it as a blocker: if any consumer pool DOES run 
Maxwell/Pascal/Volta, pinning to 580 is the CORRECT protective choice (last branch that 
supports them) -- but the fleet then can't advance past 580 until those GPUs are retired.

Deliverable: a blast-radius report stating "zero SKUs lose support: proven / not proven," 
the split of repo-confirmed facts vs what must come from John/platform owners (as yes/no 
questions), and the non-architecture residuals with evidence. Change nothing.
