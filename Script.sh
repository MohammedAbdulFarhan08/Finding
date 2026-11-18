Status correction first: SCSEC-9044 is NOT blocked anymore. Patryk approved STOI-15367 on Nov 12. The TTU svcx_golden_image is created, its password activated via Keycloak + first-login done on the SAP IaaS dashboard, and I’ve already created the OpenStack application credential through the dashboard UI (not the CLI — CLI password auth was blocked, the UI path sidestepped it, so the FIPS YubiKey never gated this). The app-cred is tested working: openstack --os-cloud ttu_login token issue returns a token scoped to DEV_SEC_GOLDEN_IMAGE, and image list returns the project’s images. So we’re at the documentation + Vault-promotion stage, not blocked.

Key facts for the docs:

TTU username: svcx_golden_image@sci-dev.scs.sap, domain iaas-de5955, project DEV_SEC_GOLDEN_IMAGE (SCI Dev, eu-de-1), project_id 00393d507aa348e5b55ec1695149c7f8.
App-cred name golden-image-upload, id c5872a726f9e41c69f5a92bb2f4e900b, roles inherited member+reader, unrestricted=No, expiry=Unlimited.
Replaces John’s personal app-cred in Vault at core-images/shared/openstack_ext_dev (kv_core_concourse mount). Only application_credential_id + application_credential_secret change; auth_url, region, floating_ip_network, network stay.
Gotcha worth documenting: a freshly-created TTU must do a first-hand login on the IaaS dashboard before the CLI/API works (the dashboard syncs the account’s resources on first login). And app-cred creation had to be done via the dashboard UI because direct CLI user/password auth isn’t supported for this account type.

Task 1 — write documentation/infrastructure/openstack-tech-user.md in the documentation repo: what the TTU is and why (moving off a person-tied cred), how it was set up end to end (CAM request → Keycloak password → dashboard first login → create app-cred in UI → Vault), the gotchas above, and how to rotate/recreate the app-cred in future. Link to the SAP Cloud Infrastructure “Technical (Team) Users and Groups” docs. Investigate the documentation repo’s structure/style first and match it. Do NOT put the secret in the doc — reference the Vault path only.

Task 2 — do NOT write to Vault yourself. Instead, give me the exact safe steps to promote the new id+secret into core-images/shared/openstack_ext_dev: that I change only those two fields, keep John’s existing values noted for rollback, and confirm via a pipeline build before retiring John’s cred. Lay it out, don’t execute.

Work on a fresh branch off main in a ticket folder. Show me the doc draft before committing; raise nothing yet.
