dropping the secret inventory here — full tiered breakdown attached. quick headlines:

• the static AWS IAM keys (UCIS class) are still on the old coreservices-* shared paths — migrating those 4 paths to the central shared/core-build/service-accounts pattern covers the whole build/share fleet in one move.
• all 11 verified live + in use, so it's migrate-then-clean-up, not delete-now (cleanup list's in the doc).
• a few refs live in the SMS Concourse foundation vault (release-ansible-roles/vault_ecr, sms-build/*) — those need the SMS platform owner to verify/migrate, can't reach them from core-images.

caveat: vault confirms the paths exist + are populated, not that the keys are still valid at AWS — happy to run a read-only AWS check to flag which are actually dead vs live if useful.
