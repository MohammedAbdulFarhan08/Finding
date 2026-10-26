Good analysis. Before picking an option, do two things in this order:

1. Run the live 2-minute check now on a fresh CDN2 Ubuntu 22.04 instance: confirm swap state, confirm whether the FIPS kernel ships the zram module (systemd-zram-generator dependency), and confirm whether apt-daily-upgrade.timer / unattended-upgrades.service is active and racing a manual apt upgrade. Report actual results, not expectations.

2. Separately, search our InSpec/STIG control suite for any control that asserts swap is disabled or that /swapfile / swap partitions must not exist. I need to know if adding swap would red the scan the way the chrony refclock control did. This decides whether this is a one-MR or a bundled roles+InSpec change.

On the swap-valve choice itself, I'm leaning A (gated disk swapfile) over B (zram), not B — because on the 2GB case zram consumes the RAM that's already exhausted during the initramfs unpack, whereas a disk swapfile gives the kernel somewhere genuinely separate to evict to. Argue me out of it if the live check shows otherwise, but default to a disk swapfile.

Whatever we add must be gated to exclude the presets that deliberately disable swap (chost / gardener-shoot / kubernetes). Don't change anything yet — come back with the check results and the InSpec answer, then I'll approve a direction.
