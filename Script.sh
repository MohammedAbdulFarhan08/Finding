SLES 16 now builds through the full base layer on aws-com. All work is on branch c5425849-sles16 (packer, roles, infrastructure) and validated build by build.

Done:

Install: SLES 16 replaced AutoYaST with the Agama installer, so the boot command, install profile and network setup were reworked (NetworkManager DHCP, since wicked is gone in 16).
repository-management: the role was hardcoded to the SLES 15 service-pack layout. I de-hardcoded it for 16’s no-SP structure and it now resolves the SLES 16 Pool repos on CDN2. SLES 15 SP5/SP6/SP7 repo output is byte-identical before and after.
Base role: added the SLES 16 OS vars/tasks and adapted for the minimal install: sudoers (moved to /usr/etc in 16, secure_path delivered via the sudoers.d drop-in), cron (not shipped on 16 minimal, needed for logrotate/aide), clamav-nextgen SLES 16 vars, and the legacy wicked ifcfg task (skipped on 16). Scoped so SLES 15, RHEL and Ubuntu behavior is unchanged.
Image-lists: SLES 16 rows added to my test list and the pre-release lists.

Open / next:

aws-cloudwatch-agent needs collectd, which is PackageHub-only on 16. PackageHub is being enabled on the repo-sync side.
Updates/16.0 isn’t mirrored to CDN2 yet (Pool only), so the image installs but can’t patch past GA until it lands.
FIPS and the DISA STIG role are next. I did a read-only pass through the repos: the SUSE STIG block in harden.yml is only gated on OS family, so it fires on 16 too, and the fips role builds a sles/16/sp0 path that doesn’t exist (16 uses the OpenSSL-3 provider model). Neither is a straight copy of 15, and DISA hasn’t published a STIG for SLES 16 yet. Planning both with Steve and Ram.
Only aws-com built so far, other clouds to follow.

MRs are held pending the release flow.
