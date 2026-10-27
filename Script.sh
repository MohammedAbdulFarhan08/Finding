Confirmed !305 is Ram's Q3 STIG review, not his SLES 16 refactor — so his 16 work hasn't started and I'm not waiting on it. Let's do everything that's independent of him. Nothing moves until I approve each step, read-only where it's investigation.

Green-lit, in this order:
1. Rebuild on the current rebased roles (552e2e8) to bank the #1/#2 InSpec clears and re-confirm FIPS + harden still go end-to-end. Force-check the roles git resource first.
2. Rebase packer onto origin/main — show me the reconciled region in the 4 golden.pkr.hcl (my Agama http_content vs main's QEMU-build-host provisioner) before pushing.
3. Rebase roles + playbooks + infra onto main (trivial per your read) — flag anything unexpected.
4. harden.yml pre-MR fix: bring my commented-out SLES-15 STIG block back as a major=='15'-gated invocation so SLES 15 keeps STIG and only 16 skips. Show me the diff.
5. InSpec #3-4 in inspec-image-tests: write the sudoers path-resolve fix. For logrotate, FIRST do the CDN2 RPM-extract check to confirm whether SLES 16 ships logrotate.conf at /usr/etc or ships none — if none, the fix goes in the base role, not InSpec. Tell me which before writing it.
6. Triage #8 (sles16_sp0.repo <500B): real missing-repo gap or just 16-has-fewer-repos? Recommend relax-threshold or not.

Leave #6-7 (aide/maxlogins) alone — deferred to Ram's future SLES 16 STIG. Leave the collectd guard removal for when Steve's mirror lands. Don't open any MR. Give me the proposed commit set after all this and I'll review before anything's raised.
