I’ve replaced the OpenStack image-upload application credential in Vault at core-images/shared/openstack_ext_dev (mount kv_core_concourse) — swapped application_credential_id + application_credential_secret to the new technical-user cred (id c5872a726f9e41c69f5a92bb2f4e900b), everything else unchanged, John’s old values kept as Vault version 1 for rollback. The new cred is tested working locally (token issue + image list both succeed).

Before I trigger a test build, I need to know whether a build will actually exercise this new cred. Investigate and tell me:

Which Vault secret does the OpenStack/Glance image-upload step actually read? Trace it through the pipeline config: does the openstack build/upload read core-images/shared/openstack_ext_dev directly, or does my personal pipeline (openstack-testing-c5425849) use its own copied secret? Find where application_credential_id/secret for the openstack upload is wired — the packer openstack template, the pipeline vars, and the Vault path the Concourse job resolves. Show me the exact file + path.
If my personal pipeline uses its own secret copy (not the shared path), tell me what I’d need to do to make a test build read the updated shared cred — e.g. update my personal secret too, or point the build at the shared path — without disturbing anyone else.
Which image/cloud is the cheapest, most reliable test that genuinely exercises the Glance upload to DEV_SEC_GOLDEN_IMAGE — openstack vs openstack-kvm, and which OS/variant builds green normally so a failure clearly isolates to the cred.
Confirm the upload stage name to watch and what a successful Glance upload looks like in the logs.

Investigate and report — don’t trigger any build or change anything yet. I’ll decide the test once I see which secret is in play.
