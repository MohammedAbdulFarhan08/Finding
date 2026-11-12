Before committing: run pre-commit and yamllint on both changed files and fix anything they flag — I don’t want a lint failure surfacing at MR time. Then rebase the branch on current main (8910 just landed) and confirm the architecture key + pipeline flag you’re using actually match what merged, not what was on John’s branch. If the merged mechanism differs from the draft, stop and tell me before changing anything.

Then you may: commit the two drafts on c5425849-ubuntu24-arm. Hold here — no push, no MR, no Vault writes, and do NOT flip create_image to true or trigger a build yet. Report: lint results, whether the merged mechanism matched the draft, and the final diff. I’ll review before we push and before anything builds.

Separately, point yourself at John’s companion ARM doc to verify the --arm pipeline flag and the exact image-list field names — I’ll get you the link. Flag any mismatch with the draft.
