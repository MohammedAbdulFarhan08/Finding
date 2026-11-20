Two updates to the inventory doc from the team:

John’s correction: the shared/coreservices-images-* keys must be LEFT ALONE — core-services is migrating those to STS keys once a few of their MRs merge. So reclassify those 4 paths as “leave alone — core-services moving to STS (in flight), not ours to touch.” Remove the old “migrate these 4 to service-accounts covers the fleet” recommendation.
Steve’s design direction: the goal isn’t just consolidating creds to one shared path — it’s REDUCING SCOPE to per-use-case creds instead of large shared ones. Each activity should have its own narrowly-scoped credential (ECR-only for container pulls, a separate scoped cred for clamav mirroring, stemcell, galaxy, etc.) — least-privilege, so a leak/deactivation of one only affects that one use case, not everything.

Add a “Target design / recommendations” section that captures this: for each major activity (ECR pull, clamav-cvd-mirroring, ansible-galaxy-mirroring, stemcell, repo-sync, image-sharing, etc.), note what it currently uses (shared/broad vs scoped) and what a per-use-case scoped cred would look like. Flag where we’re over-broad today (one shared key doing many things) as the things to split out.

Keep the current-state inventory (tiers, paths, SMS-scope split) as the factual base, and update the GI-team scope to: per-pipeline vault_variables static keys + the SMS-foundation refs. Then layer Steve’s scoping principle as the forward-looking recommendation. Markdown file, same as before. No infra changes — doc only.
