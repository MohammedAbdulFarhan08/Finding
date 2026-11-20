Add one more point from John to the target-design section:

Dependency note: the coreservices-images-* → STS migration is blocked on core-services being slow to merge (the STS MR bumps their terraform module, they’re cautious about breaking things). So that’s in-flight-but-stalled, not imminent — flag it as a dependency we don’t control.
Short-lived creds principle (John): beyond scoping per-use-case, the direction is short-lived creds on everything. Importantly, the Golden-Images-team’s OWN Vault keys (the per-pipeline vault_variables static keys) could move to short-lived / renewable (like the vault-renewable-tokens pattern already in Tier 3) WITHOUT waiting on core-services — that’s within our control. Call that out as the actionable, team-owned path: scope + shorten our own keys now, while the coreservices-* STS move waits on core-services.

So the target design has two tracks: (1) what we can do now on our own keys (scope per-use-case + make short-lived/renewable), and (2) what’s dependent on core-services (the coreservices-* STS migration, stalled on their merge).
