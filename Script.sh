Research and investigation only — do not change anything, no branch, no commits. I want the full picture before we touch it.

Ticket STOI-14841 (azure-cli). On the Azure RHEL golden images, azure-cli is installed as an old version via pip (pip3.9 on system python, az at /usr/local/bin/az, currently 2.37.0) rather than as an rpm — rpm -qa | grep az-cli returns nothing. Tenable scans flag the stale pip version as out of compliance. The intended fix direction is to install azure-cli from the Microsoft rpm repo (packages-microsoft-com-prod) so it stays patched and clears the scan — but don’t implement anything, just investigate and propose.

This already happened once — treat that as the main clue. It’s a recurrence of a ticket closed as “fixed” mid-2026, where the same pip→rpm migration was supposedly done. It came back on a newer image. The note from that old ticket: azure-cli gets touched in several places from base through hardening, with duplicated and possibly conflicting code. So the single most important thing: find EVERY place azure-cli is installed, modified, pinned, or pathed across all the repos — base build, provisioners, roles/hardening, inspec, wherever — and show me how the current pip install actually lands on the image and why the earlier rpm migration didn’t stick (overwritten, a leftover pip step, ordering, etc.).

Scope / blast radius. The ticket names one image (Golden-CDN2-SCS-RHEL-9.6-Base), but I’m told this likely affects ALL azure-cli installs, not just that one. Map the real footprint: which OS families, images, clouds, and partitions install azure-cli, and whether the install path is shared, so I know the true blast radius of a pip→rpm switch.

FIPS. I’ve been warned azure-cli “gets funky on FIPS,” and our build hosts recently moved to a FIPS metal cluster. Investigate the FIPS implications for both the current pip install and the proposed MS-repo rpm (python version, the python3.12 deps the rpm pulls, any crypto/cipher issues).

Fix viability. Check whether packages-microsoft-com-prod is defined/available/mirrored for the relevant OSes and partitions, what version + dependencies the rpm pulls, and whether the pip install can be removed cleanly without conflict.

Report back with: (1) the full map of where az-cli is touched and why it recurred, (2) a proposed approach that fixes it for good, (3) the blast radius, and (4) an explicit list of open questions or things only John / the platform owners would know.
