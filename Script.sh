Both corrections confirmed — finalize the inventory doc with the sweep results, and save the resolution model to your notes. Specifically:

Fix the service-accounts path throughout: the real location is kv_core_concourse/shared/core-build/service-accounts/svc-ecr-concourse (true shared path, rotated 2026-11-19) — not the inferred team-relative core-images/core-build/... path.
Add a clear “SMS-foundation scope” callout: split out the refs that live in the SMS Concourse foundation’s Vault (not reachable with the core-images token) — sms-build/*, top-level service-accounts/*, and release-ansible-roles/vault_ecr. Mark these as “needs the SMS platform owner to verify/migrate,” since we can’t touch them from core-images. Note release-ansible-roles is confirmed from code to still use the old vault_ecr pattern but needs SMS-side verification.
Tier-1 headline: all 11 static keys verified live + in-use (not orphaned) — so they’re migrate-then-clean-up, not delete-now. Call out that migrating the 4 coreservices-* shared paths covers the whole build/share fleet in one move (the per-pipeline objects only hold passwords/SSH/GCP/OpenStack — the Tier-4 set).
Keep the tiered structure + the cleanup list (old paths to retire, ordered after each consumer is re-pointed and re-baked).

Write it to a clean markdown file I can share with the team. And save the confirmed shared/core-build/service-accounts path + the Concourse secret-resolution model to your notes so the next migration session doesn’t re-derive it.

Do NOT touch Vault, any pipeline, Concourse, or any repo — no secret writes, no bootstrapping, no MRs. The only things you write are the local markdown report and your own notes. This stays an inventory/documentation task only.
