SLES 16 is validated and John cleared it to merge. Do the pre-MR cleanup on the SLES 16 branches (c5425849-sles16 across packer, ansible/roles, ansible/playbooks, infrastructure), then prep for MRs. Investigate and show me the plan + diffs BEFORE committing anything — do not raise the MRs yet.

Cleanup to do:

Strip the SELinux AVC debug dump from all four packer templates (it was a diagnostic, not for production) — show me each removal.
Reset all test-only pointers in test_c5425849_build.yml back to main — the branch pointers for roles/playbooks/infra/inspec and any test image-list pointer. Nothing test-only (local build-file pointers, the test image-list additions) can go into an MR. List exactly what you’re resetting.
Restore the harden.yml SLES-15 STIG block — it was commented out (gated os_family=='suse' so it covered 15 AND 16); bring it back as a major=='15'-gated invocation so merging doesn’t strip STIG from SLES 15 production. This is critical — confirm the gate is major=='15', not os_family=='suse'.
Rebase all four repos onto current main and resolve any conflicts; report what conflicted. Flag any CHANGELOG collisions like we hit before.
Any other test-only / diagnostic artifacts you find staged on these branches (collectd guards, dead-end commits), list them for me to decide — don’t drop silently.

Then STOP and show me: the full cleanup diff per repo, the rebase result + any conflicts, and confirmation the SLES-15 STIG block is restored and major=='15'-gated. Do NOT raise MRs, do NOT merge — I review first, then we bundle roles+packer+infra+inspec and raise them together (roles merges first/with the others, per the bundling rule).
