John — quick one on STOI-14396. Goncalo wants us to move 535 → 580.178.04 (lifecycle — 535's EOL, 580's the LTSB). Checked it against NVIDIA's 580 notes and it covers everything 535 did, so no SKU loses support.

Before I push it though — what's your read? The nvidia preset's shared across all Gardener-Nvidia images/partitions, so it hits every GPU consumer, not just the H200. Mainly wondering if you know of anyone pinning a 535 driver/CUDA, or anything besides the GPU pools using that preset. Want your eyes on the blast radius first.
