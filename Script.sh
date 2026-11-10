New ticket: [paste SCSEC ticket link] — move the OpenStack image-upload application credentials off John’s personal account onto a non-person technical user. I’ll paste the SAP docs links John shared below. Investigate and draft first, then hold — no credential creation, no Vault writes, no requests raised, nothing pushed, until I give the word. You have the repos and OpenStack CLI access; we’ll default to the UI for the actual credential work and only fall back to CLI if the UI can’t do it.

The goal. The build-image pipeline authenticates to OpenStack for image upload using credentials tied to John personally. We want those replaced with a technical (team) user’s so the upload path doesn’t depend on any individual. The credentials live in Vault at core-images/shared/openstack_ext_dev and the account is the DEV_SEC_GOLDEN_IMAGE project.

What I know going in (confirm against reality, don’t just trust me): only application_credential_id and application_credential_secret in that Vault secret are person-tied; auth_url, region, floating_ip_network and network should stay. If your investigation shows a technical user needs a different auth_url, scoping, or roles for the upload to work, flag it — that changes the plan.

Figure out the full picture and come back with a plan. Read the SAP “Technical (Team) Users and Groups” docs (links below — curl/pandoc them if that helps; tell me if anything’s gated and I’ll paste it). I want to understand: which of technical user vs technical team user vs Keystone group is right for a shared pipeline credential and why; the real request/approval path and how long it takes; how the user gets into the project and how the app credential is created under it; the lifetime/rotation rules and what breaks uploads when they lapse; and how the pipeline actually consumes these creds (trace it in the repo so we know exactly what has to match when we swap them). Then tell me the end-to-end approach, what needs my hands/approvals, and the blast radius — who/what else uses this credential and could break during the swap.

Deliverable alongside the plan: draft openstack-tech-user.md in the documentation repo under infrastructure/, matching the existing build-host docs’ style — how the technical user is requested, the credential created, where it lands in Vault (new version of the same path), and how to test an upload. Mark clearly which steps you’ve verified vs which are only from the docs, and leave placeholders for the steps I’ll run by hand.

Don’t print or store any secret values. When we get to the real credential, I’ll enter it straight into Vault, not through the chat. Report findings + plan + the doc draft, then hold for my go.

Docs John shared:
[paste links]
