Add a short note to documentation/infrastructure/openstack-tech-user.md (on the branch the doc is on) recording where the TTU’s login password is stored, so the team knows where to find it to manage the account.

Facts:

The TTU login password (for svcx_golden_image@sci-dev.scs.sap) is stored in Vault at core-images/shared/technical-users-golden-image (mount kv_core_concourse). It holds the username + password.
This is SEPARATE from the application credential, which is at core-images/shared/openstack_ext_dev and is what the pipeline uses. Make the distinction clear: the app-cred = what the pipeline authenticates with; the login password = for a human to sign into Keycloak/the dashboard as the TTU to manage the account (rotate the app-cred, register keypairs, etc).
Put this in the Account Details section (or near it) — wherever it reads most naturally alongside the existing app-cred/Vault references.

Important: reference the Vault PATH only. Do NOT write the actual password (or the app-cred secret) into the doc. Show me the added lines before committing.
