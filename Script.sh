SLES 16 cross-cloud: mirror pre-check — read-only, NO builds/commits/pushes. Before we port 
the enforce-flip provisioner and run per-partition builds, I need to know whether the SLES 16 
packages actually resolve on the gov and ESC mirrors — same per-partition mirror risk we hit 
on NVIDIA GovCloud. We've only ever validated against the commercial mirror (aws_commercial, 
build #40). Evidence/paths for every answer; if something can't be confirmed read-only, say 
what build/step would confirm it.

Context: SLES 16 targets 8 partitions. Mirrors are per-partition — commercial CloudFront, 
us-gov-west-1.repositories.images.scs.sap (GovCloud), eusc-de-east-1.repositories.images.scs.sap 
(ESC/EU-Sovereign). Memory notes Updates/16.0 isn't even on the commercial mirror yet, so 
gov/esc are likely further behind.

1. CONFIRM THE MIRROR HOSTNAMES per partition from the repo (repository-synchronization / the 
   per-partition mirror config), so we're checking the real URLs, not assumed ones. List the 
   mirror hostname + base path for: aws_commercial (baseline), aws_govcloud, aws_esc, and the 
   Azure/GCP/OpenStack mirrors if they differ.

2. RESOLVE-CHECK the SLES 16 package set on EACH mirror (gov + esc are the ones that matter; 
   include commercial as the known-good baseline). For each mirror, confirm whether the SLES 16 
   Pool is present and whether these packages resolve:
   - selinux-policy-targeted
   - policycoreutils
   - policycoreutils-python-utils
   - selinux-autorelabel
   - (and the base SLES 16 product itself — the product IDs Steve's sync config added: 
     SLES 2930, SLES_SAP 2985, sle-ha 2937, PackageHub 3137)
   Use a read-only fetch of the mirror's repo index / Pool path (the way we confirmed the 
   NVIDIA triplet on the gov mirror — curl the package index, grep the names). Do NOT build.
   If you can reach the mirror indexes from here, report exact presence per package per mirror. 
   If a mirror isn't reachable read-only from this environment, say so and tell me the exact 
   curl/command to run from a build host that would confirm it.

3. VERDICT per partition: for aws_govcloud and aws_esc specifically — is SLES 16 + the full 
   SELinux stack mirrored and resolvable (→ safe to validate there), or is the mirror behind 
   (→ Steve/mirror-sync dependency before we can build enforcing there)? Name exactly which 
   packages are missing where, if any.

4. Also confirm whether Updates/16.0 (the updates/security pocket) is present on each mirror — 
   since our SELinux config and pins may pull from updates, not just the base Pool, and that's 
   the pocket memory flags as not-yet-live on commercial.

Deliverable: mirror hostname list, a presence table (mirror × package), and a clear 
per-partition verdict — which partitions are mirror-ready to build/validate now vs which are 
blocked on mirror sync (Steve). Change nothing. This decides what we port and build next, and 
what we hand to Steve.
