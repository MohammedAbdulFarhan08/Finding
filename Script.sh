Steve/John want an inventory of the NON-image-building pipelines (the mirroring/sync/support pipelines, not the golden-image build ones) — a bunch have been red for a while, and we need to normalize alerting and assign owners. This is read-only inventory + diagnosis, change nothing.

Work from a current checkout of main (pull main first so it’s fresh). This is a report, not a code change — don’t create a feature branch or modify any repo.

In the Concourse core-images team, identify all the NON-image-building pipelines — e.g. the clamav-cvd-mirroring (commercial/gov/esc), ansible-galaxy-mirroring (commercial/gov/esc), repository-synchronization (+cdn1), trivy-grype-mirroring, container-management, aws-image-validation (cdn1/cdn2), image-sharing-* , and any other support/mirror/sync pipelines. Exclude the actual golden-image build pipelines and the personal testing pipelines (c5425849).

For each one, produce a table with:

Pipeline name and what it does (purpose).
Current status — is the latest build red/green, and if red, HOW LONG it’s been failing (how many builds / since when).
Why it’s failing — trace the actual error from the build logs (e.g. the ansible-galaxy S3 config profile could not be found cred error, the clamav 1.5.5 rpm conflict, ECR-not-bootstrapped, etc.). Group common root causes.
Owner — who owns it today, or flag “UNOWNED” if no clear owner. Check CODEOWNERS / recent committers / pipeline config for clues.
Alerting — does it have failure alerts/notifications configured, and are they firing correctly.

Order it: longest-red / unowned first (the urgent ones). Then a summary grouping the failures by root cause (credential/bootstrap vs packaging vs other), so we can see what’s a quick fix vs needs an owner. Read-only — inspect Concourse + repo config, run no pipelines, change nothing.
