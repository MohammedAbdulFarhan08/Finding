INVESTIGATE the repository-management / CDN2 blocker — READ-ONLY. Make NO commits,
do NOT branch the roles repo, do NOT touch the CDN2 mirror or any sync job. Report
findings and stop.

Context: SLES 16 CREATE fails in the repository-management role — "no repositories
reachable"; it computed sles16_sp[0].repo and CDN2 has no SLES 16 content. Same
blocker SLES 15 SP7 is stuck on. Two separate sub-problems to map:

1) THE ROLE VERSIONING BUG — what's the exact fix?
   - In the repository-management role (sles-repo.j2 + defaults/main.yml SLES
     presets), diff how SP6 (working) computes its .repo file vs what SLES 16 does.
   - Determine precisely: is the SP-style name (sles16_sp[0]) a MISSING PRESET (a
     small add for a no-Service-Pack version), or does the role's SLES version
     logic HARDCODE the _sp pattern (a deeper change)?
   - Report the exact fix and its size. Do NOT apply it.

2) THE CDN2 CONTENT MECHANISM — who/what populates the mirror?
   - Find how SLES content gets onto CDN2 (release.repositories.images.scs.sap):
     the repository-synchronization playbook/pipeline (look in ansible/playbooks for
     repository-synchronization-*, and pipelines/concourse for anything that syncs
     repos) and its config.
   - Determine: is there a config listing which SLES versions get synced, and are
     SLES 16 (and SP7) simply missing from it — OR does it also require upstream
     SLES 16 repo content to exist / be subscribed first (something a config change
     alone can't satisfy)?
   - Report the mechanism, where the config lives, what adding SLES 16 would
     involve, and which part (if any) is outside a repo change (actual mirror
     population / subscription). Do NOT run any sync or edit any config.

GOAL: turn two vague questions for John into precise ones — "the role fix is X
(size Y); the sync config is at Z and SLES 16 is missing from it; the content step
is <a config change I can make> vs <infra/subscription someone owns>."

HARD RULES: read-only; no commits; no roles-repo branch; never touch the CDN2
mirror, Vault, or any sync/drift job; no changes to main. Hold at findings — I'll
take the ownership calls to John.
