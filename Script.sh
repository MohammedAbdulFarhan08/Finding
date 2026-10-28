New ticket STOI-14396 — NVIDIA Fabric Manager on the Gardener-Nvidia golden images. I've talked to John and his guidance OVERRIDES the ticket's literal request where they differ, so read this carefully before touching anything. Investigate first, change nothing until I approve.

Background: the Gardener-Nvidia images install the NVIDIA driver (nvidia-driver-535-server) but NOT NVIDIA Fabric Manager. On single-GPU nodes that's fine; on NVSwitch multi-GPU nodes (H200) Fabric Manager is mandatory to init the NVSwitch fabric, and without it the GPUs are dead. There's a live incident: 5 H200 nodes broken in AI Core preprod. The reporter (Goncalo) asked us to bump the driver to 580.196.07 and add fabricmanager-580 + libnvidia-nscq-580, all pinned to 580.196.07, and enable the service.

John's guidance, which is what we actually follow:
1. Fabric Manager — add it to everything that has NVIDIA packages. Gardener-Nvidia for certain, Ubuntu AND SLES. Fabric Manager MUST be pinned to EXACTLY the driver version the image actually ships, or it won't start.
2. Do NOT blindly bump the driver to 580. Bumping a driver risks breaking other consumers. Instead: verify what driver Ubuntu 22.04 Gardener-Nvidia currently ships and what Ubuntu 24.04 ships. If 24 already ships 580.196.07 or newer, we'll recommend Goncalo use the 24 image rather than changing 22.
3. Check whether Gardener-Shoot installs any NVIDIA packages at all — John thinks maybe not. If it does, Fabric Manager goes there too; if not, leave it alone.

What I need from you, in order, read-only:
1. Find where the NVIDIA packages get installed — grep packer and the roles for "nvidia". Which image names / presets trigger it, and what exactly is installed and validated today (the ticket says validation runs nvidia-smi on a single-GPU g4dn.xlarge, so Fabric Manager was never exercised — confirm).
2. Report the current driver version in the Ubuntu 22.04 Gardener-Nvidia build vs the Ubuntu 24.04 one. If you can't read it from config alone, tell me what needs a live build to confirm.
3. Does Gardener-Shoot pull NVIDIA packages? Yes/no with where you saw it.
4. Is 580.196.07 (driver + fabricmanager + libnvidia-nscq) actually on our SCS mirror? The ticket claims it is — verify.
5. Which image-list entries (Gardener-Nvidia, and Shoot if relevant) are create_image:false in my test list and would need enabling to build — Ubuntu 22, Ubuntu 24 metal, and the SLES Gardener-Nvidia. Don't change them yet, just list them.

Then propose the change (Fabric Manager pinned to each image's real driver version, plus the 22-vs-24 driver recommendation) and I'll approve before anything moves. Working folder is c5425849-nvidia.
