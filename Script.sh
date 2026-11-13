Goal: make the Ubuntu sources arch-conditional in repository-management so aarch64 resolves against default-ports while amd64 continues to resolve against default, so the ARM build’s dist-upgrade pulls cleanly. The locus is the Ubuntu sources template (ubuntu-sources.list.j2 per the diagnosis) — but investigate how it renders and everything that consumes it before changing anything.

Constraints:

Scope it surgically. Only reroute when arch is aarch64 and OS is Ubuntu. amd64 and every other OS (RHEL, SLES) must render byte-for-byte identical to today — prove that with a before/after, don’t assume it.
Cover the base suite plus -security and -updates (noble, noble-security, noble-updates).
Stay on branch c5425849-ubuntu24-arm. No commit, no push. Investigate → analyze blast radius → propose the diff plus the rendered amd64 and aarch64 sources for my review.
Don’t touch the mirror side. Steve’s default/ InRelease advertising arm64 is a separate mirror cleanup, harmless once arm64 stops querying default/, and not a dependency for this fix.
