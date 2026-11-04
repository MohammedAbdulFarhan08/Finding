Goal: deliver SLES 16 enforcing across all CDN2 target partitions, not just aws_commercial. 
You've already validated aws_commercial (#40). The roles/inspec work is cloud-independent; the 
only cloud-specific piece is the SELinux enforce-flip + AVC-dump provisioner, which currently 
exists only in aws/golden.pkr.hcl. Port it to the other CDN2 templates and validate per 
partition. Include Azure this time — add SLES 16 to the test image-list so azure builds.

You have repo access and can research whatever you need — don't ask me to hand you context you 
can find. Work autonomously. The standing rules from how we've worked this whole ticket still 
apply:
- Boot-critical and shared-file changes: show me the diff and wait for my ok before applying. 
  Everything else, just do it.
- Don't trial-and-error with builds. Do the research first, make the change right, then build 
  to validate — not build to discover.
- Follow the vendor default, keep changes OS/partition-gated so nothing leaks to other OSes or 
  the commercial path, and never claim something's validated that a build hasn't proven.
- Flag honest caveats; a green test over a silently-broken thing is the worst outcome.

The work:
1. Port the enforce-flip + AVC-dump block from aws/golden.pkr.hcl into azure, gcp, and 
   openstack golden.pkr.hcl — verbatim behaviour, it already self-gates on ID=sles + 
   VERSION_ID=16 so it's inert on other OSes. Confirm each template's structure actually 
   supports it where you place it (don't assume aws's layout matches the others). Show me the 
   three diffs before applying — this is the fan-out change, I want eyes on it.
2. Add SLES 16 cHost to the test image-list (test-c5425849-image-list.yml) for the partitions 
   it's missing from, Azure included, so these can actually build. Show me what you're adding.
3. Confirm, from repo logic, that all CDN2 partitions pull SLES 16 from the single commercial 
   CloudFront endpoint at build time (we established this, but re-confirm it holds for azure/
   gcp/openstack specifically) — so there's no per-partition build-time mirror dependency on 
   the CDN2 path. If any partition deviates, flag it.
4. Then validate, cheapest-signal-first, and stop if any build fails rather than churning:
   - gcp_commercial first (proves the port on one cheap partition)
   - openstack + openstack_kvm (validate BOTH — kvm has its own image name/boot handling)
   - aws_govcloud + aws_esc (aws template already has the flip; before the first gov build, 
     run a read-only build-host check that the SLES 16 Pool + SELinux stack actually resolves 
     on the gov/esc build worker — architecture says it uses the commercial endpoint, but 
     verify once from the right host, don't assume)
   - azure_commercial + azure_government (needs the test-list entry from step 2)
   Each partition's pass criteria = the #40 hard gate: getenforce=Enforcing, relabel done, 
   zero AVC denials against sshd/chronyd/clamav/nessus/cwa/ssm, SSH connects with sshd reading 
   the hardened drop-in, plus logrotate single-cap and sudoers green.

Report per partition as you go: validated / failed-and-why. Strip any temp diagnostics before 
MR. Note anything that's a Steve/mirror or other-owner dependency (e.g. CDN1 gov/esc is a 
separate build path, out of scope here). Keep the MRs held per the standing hold.

Start with the port diffs (step 1) + the test-list additions (step 2), show me both, then 
proceed.
