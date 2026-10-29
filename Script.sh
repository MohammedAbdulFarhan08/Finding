Hey Steve — John pointed me your way on this one. On STOI-14396, Goncalo wants us to move the Gardener-Nvidia images off the 535 driver to 580.178.04 — purely lifecycle (535's near EOL, 580's the current LTSB, and .178.04 is the R580 we've got on the mirror).

Driver side I've already checked: per NVIDIA's own 580 release notes, 580 supports everything 535 did (Maxwell on up), so no SKU loses support — clean superset, not a risky jump.

What I'd like your read on is blast radius. The nvidia preset's a single shared file across every Gardener-Nvidia image/partition, so this bumps the driver for every GPU consumer, not just the H200s. Two things I can't tell from the repo:
1. Any consumer you know of that pins a specific 535 driver / CUDA version that a 580 jump would disturb?
2. Is that preset only used by the GPU pools, or do other images pull it in too?

If you reckon nothing would break, I'll push the swap and raise the MRs. Thanks!
