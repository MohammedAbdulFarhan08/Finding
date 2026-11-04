SLES 16 cross-cloud scoping — read-only, NO builds/commits/pushes. We're responsible for 
delivering SLES 16 across all its target clouds and validating on each. So far everything 
(build #40, SELinux enforcing, logrotate, sudoers) is validated on aws-com ONLY. I need to 
know the real scope before porting or building anything. Evidence/paths for every answer; if 
something isn't determinable from the repo, say so.

1. TARGET CLOUDS: from the image-lists / cloud_partition config / release definitions, which 
   clouds+partitions is SLES 16 actually a build target for? List them explicitly (aws-com, 
   aws-gov, azure, gcp, openstack/kvm, metal — whichever apply). For each, say whether SLES 16 
   is already listed as a target or not yet added. I don't want to validate a cloud SLES 16 
   doesn't ship to, nor miss one it does.

2. PER-CLOUD GAP INVENTORY: for each target cloud from #1, compare its packer template 
   (azure/gcp/openstack/metal golden.pkr.hcl) against aws/golden.pkr.hcl for everything our 
   SLES 16 work depends on. Specifically:
   - the SELinux enforce-flip provisioner (we KNOW this is only in aws/golden.pkr.hcl — confirm 
     which other templates lack it)
   - the SLES 16 http_content / sles16.xml wiring (the agent said it's in all four — verify 
     per cloud)
   - any AVC-dump/validation hooks, FIPS handling, or SLES-16-specific provisioner that exists 
     in aws but not the others
   Produce a table: cloud | SLES16 a target? | enforce-flip present? | sles16 wiring present? | 
   anything else missing. This is the port checklist.

3. CLOUD-SPECIFIC RISKS: flag anything that differs by cloud that could make the same change 
   behave differently — e.g. GovCloud mirror (does SLES 16 / the SELinux packages resolve on 
   the gov mirror, like we checked for NVIDIA?), Azure/GCP image sources, metal/openstack boot 
   or partition differences. Don't assume the aws result carries; name what needs per-cloud 
   confirmation.

4. ROLES/INSPEC PORTABILITY: confirm the roles + inspec work (logrotate, sudoers, SELinux 
   enabling) is genuinely cloud-independent (gates on OS/release, never cloud) so it needs NO 
   per-cloud change — only the packer provisioner layer does. If anything in roles/inspec is 
   secretly cloud-gated, flag it.

Deliverable: the target-cloud list, the per-cloud gap table (the port checklist), the 
cloud-specific risks to validate, and a recommended build/validation order (which clouds, in 
what sequence, and which can share vs need separate runs). Change nothing — this is the plan, 
not the work.
