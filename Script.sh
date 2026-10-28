Go with option 1 — make the exclusion on a fix branch in inspec-image-tests, point my test context at it, re-run both builds. This is the chrony pattern exactly: the service legitimately can't start on a GPU-less builder but works on real H200, so the scan needs to expect it — same as the refclock control. Agreed on not un-enabling FM and not adding a GPU condition; leave FM's runtime behavior untouched, only teach the scan.

Use the existing conditional-exclusion precedent (update-gardener-node-init.service etc.) — FM is the same shape, exclude only on ExecMainStatus=1.

This is now a bundled two-repo change (roles + inspec), so we follow the same rule as chrony: test both together, raise them together, and the inspec MR gets approved before roles merges. After the re-run, show me: both create builds green, the FM packages installed at 535.309.01, the service enabled, and the scan passing with the new exclusion. Then I'll raise the two linked MRs.
