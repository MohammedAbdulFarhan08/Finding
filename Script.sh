Driver version: decide after mirror check.
Mirror check: yes, query the mirror (apt-cache madison on jammy + noble, read-only) for driver/fabricmanager/nscq at both 535.288.01 and 580.196.07.
Scope: Ubuntu 22.04 + 24.04 together now (shared preset, and I need 24's driver for the comparison anyway). Hold SLES as a separate follow-up — it's a different zypper path and John wasn't sure it's in scope for this ticket. Still verify whether Gardener-Shoot pulls NVIDIA, but don't change it.

After the mirror check, come back with: what each image ships today (22 vs 24 driver), what resolves on the mirror, and your recommended driver line (keep 535 + add FM, or point them at 24) — I'll pick before any change.
