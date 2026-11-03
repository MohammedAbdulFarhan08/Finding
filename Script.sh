Two goals, both read-only / investigate-first — do NOT commit, push, or build until I approve. 
Evidence for every claim; if something can't be confirmed from the repo/build output, say so.

GOAL 1 — close the /usr/etc InSpec fails that are genuinely ours.
The 5 remaining SLES 16 InSpec failures: aide + maxlogins are Ram's (SLES 16 STIG), repo-file 
<500B is Steve's (mirror). Leave those alone. The other two — sudoers-config and 
logrotate-config — look like /usr/etc stateless-split issues where the IMAGE is correct (our 
drop-in delivers the right config) but the InSpec TEST checks the literal /etc path that SLES 16 
no longer uses.

For each of those two:
1. Confirm which is actually wrong — the image or the test. Show where the real file lives on 
   SLES 16 (/etc vs /usr/etc), what our roles write, and what the InSpec control asserts. Quote 
   the exact failure.
2. If the IMAGE is wrong, stop and tell me — that's a real fix, different conversation.
3. If the TEST is wrong (checking /etc when 16 uses /usr/etc), draft the fix in 
   inspec-image-tests: make the control /usr/etc-aware for SLES 16 WITHOUT changing what it 
   asserts for SLES 15 / RHEL / Ubuntu. Gate by OS/release the same way the existing controls 
   do. Show the before/after.
4. Confirm these two are in a repo/area we own to change (inspec-image-tests). If either is 
   actually someone else's owner, say so and don't touch it.

GOAL 2 — regression check: prove our SLES 16 work hasn't broken anything else.
Everything we changed this cycle for SLES 16 — the SELinux task, the GRUB cmdline edit, the 
base package list, the packer enforce-flip provisioner, the InSpec changes, and anything in 
shared files — I need confidence it only affects SLES 16 and leaves every other OS/variant 
exactly as before. Check specifically:

- SHARED FILES: for every file we touched that is NOT SLES-16-exclusive (e.g. base/tasks/grub.yml, 
  base/tasks/main.yml, anything in inspec-image-tests, packer golden.pkr.hcl / the per-cloud 
  hcls), show that our additions are gated (when: SLES16 / os.release 16 / cloud conditionals) 
  and that the non-16 code paths are byte-unchanged in behaviour. List every shared file touched 
  and the guard on each change.
- OTHER OSes: confirm RHEL, Ubuntu, and SLES 15 build/harden/InSpec paths are unaffected — no 
  package added to their lists, no GRUB arg added to their cmdline, no InSpec assertion changed 
  for them, no role that now runs on them that didn't before.
- THE GRUB EDIT especially: confirm the security=selinux selinux=1 change and anything near the 
  fips handling fires ONLY on SLES 16 and cannot alter the cmdline on any other OS. This is the 
  one that could brick a boot elsewhere, so be thorough.
- THE SHARED selinux-apparmor ROLE: confirm we did NOT touch it, so Shoot/Nvidia/other consumers 
  of it are exactly as before (we know there's a latent Shoot/Nvidia-on-16 issue there — that's 
  pre-existing and separate, not something our change introduced or fixed).
- INSPEC: confirm the apparmor-status exclusion and the new selinux-enforcing-sles16 control are 
  both gated to SLES 16 only and don't change pass/fail for any other OS.

Report: (a) the two /usr/etc fixes as drafts (or "image is wrong, stopping"), and (b) a 
regression table — every shared/non-16 file touched, the guard on it, and a clear yes/no on 
"non-16 behaviour unchanged." Flag anything you're NOT sure is fully isolated. Wait for my 
approval before changing anything.
