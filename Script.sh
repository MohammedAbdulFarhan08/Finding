Steve wants a full inventory of all secrets our pipelines use and their Vault locations — context: UCIS force-deactivated static long-lived IAM keys, pipelines broke, and the team wants everything moved to dynamic, centrally-updated Vault paths so this can’t break us again. Read-only, change nothing.

The TARGET pattern is already established — John moved the ECR keys to core-build/service-accounts/<svc-account> (e.g. ((core-build/service-accounts/svc-ecr-concourse.aws_access_key_id))). Concourse consumes these directly, and they’re dynamically/centrally updated. That’s the “good” state. Steve also wants all the OLD per-pipeline secret paths cleaned up once things are migrated.

Inventory every secret/credential the pipelines reference, and for each capture:

What it is (AWS IAM key, OpenStack app-cred, ECR key, API token, etc.) and its purpose.
Its exact Vault path (mount + path), and whether it’s on the NEW core-build/service-accounts/... pattern or an OLD per-pipeline path.
Static long-lived key (at-risk from UCIS) vs already dynamic/central.
Which pipelines/clouds consume it.
Migration status: already on core-build/service-accounts (done — like ECR), or still on an old path and needs moving. For the old ones, note the old path that can be cleaned up after migration.

Trace how Concourse resolves secrets (((...)) references), list every distinct one, and give me a table I can share with the team. Order it: at-risk static keys still on old paths first (urgent), then already-migrated ones. Don’t modify anything — inventory + migration-status + cleanup-list only.
