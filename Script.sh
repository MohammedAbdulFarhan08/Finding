Both !382 and !111 merged back-to-back (STOI-14841). Quick check, no changes:

Has a fresh image built from main since !382 merged — i.e. does an image exist now that actually contains the MS-repo rpm fix, or is the latest built image still pre-fix?
When does the InSpec guard (!111) run — only as part of a build against the freshly-built image, or also against existing/published images on a schedule? That tells me whether the back-to-back merge can red a pipeline before a new image builds.

If a post-!382 image already built (guard passes against it) → we’re clean, nothing to do. If not, and InSpec can run against pre-fix images → flag it, and the fix is just to trigger/await a fresh build so the guard validates against an image that has the rpm. Tell me which case we’re in.
