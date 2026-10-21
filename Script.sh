I'm working on SLES 16 FIPS enablement for the golden images (SCSEC-8697, branch
c5425849-sles16). Steve has told me to comment out the hardening/STIG roles so the
build can get past them, and focus on getting FIPS working for 16.

Two things to do:

1. PIPELINE UNBLOCK — In ansible/playbooks/harden.yml, find the SUSE DISA STIG block
   (the one gated on ansible_os_family | lower == 'suse', around line 248-270). I need
   to comment it out on my branch so builds get past hardening. DON'T touch
   base-configure.yml — that one is already correctly version-gated. Also comment out
   any other hardening role calls that would fail on 16 for the same reason. Show me
   the diff before committing.

2. FIPS RESEARCH (read-only) — Before writing any FIPS tasks:
   - Search the SUSE documentation for how FIPS 140 is enabled on SLES 16. Key things
     I need to know: is it still fips-mode-setup, or is there a new method? Does it
     use the openssl 3 provider model (libopenssl-3-fips-provider)? What's the
     bootloader situation — grub2-mkconfig or sdbootutil/systemd-boot?
   - Then read the existing fips role in the repo, specifically the SP6 enable-fips.yml
     (fips/tasks/sles/15/sp6/enable-fips.yml) since that's the closest model — it
     already uses libopenssl-3-fips-provider.
   - Compare vendor docs against SP6 tasks and give me a gap list: what carries over,
     what breaks, what's unknown.

Do step 1 first (show diff, wait for my ok to commit). Then do step 2 as a research
output — no file changes, just the findings.
