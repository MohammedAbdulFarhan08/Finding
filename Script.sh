Before I test and MR the Fabric Manager fix, I want to know the full blast radius — am I fixing everything that needs it, or just Ubuntu Gardener-Nvidia? Read-only, change nothing. Tell me:

1. Every golden image across ALL OSes and variants that installs NVIDIA anything (driver, fabricmanager, cuda, nscq) — grep packer and all roles for nvidia/cuda/fabricmanager. List each image name and which task/preset installs it.
2. For each: does it already go through the base/tasks/products/nvidia.yml task I just edited (so it's covered by my fix), or does it have its own separate NVIDIA install path (so it's NOT covered)?
3. Specifically confirm whether Golden-Metal-CDN2-SCS-Ubuntu-24.04-Gardener-Nvidia (the metal variant named in the ticket) shares my edited task or has its own.
4. Confirm the SLES Gardener-Nvidia situation — you said it installs no driver at all. Which images, what preset, and roughly what a SLES driver+FM install path would take (so I can size the separate ticket).
5. Any NVIDIA on RHEL or any other OS family, or is it Ubuntu/SLES only?

Just the inventory and what's covered vs not. I'll decide scope from there.
