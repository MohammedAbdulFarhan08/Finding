Apply Change A — but first add /etc/default/grub to a quick read-only diagnostic and show me 
the ACTUAL GRUB_CMDLINE_LINUX_DEFAULT line. I don't want to apply a boot-critical regex against 
a derived line when we can see the real one. If it matches the shape you assumed, apply A.

Change B: go with B1 (root-cause, order-independent) — NOT B2. But do it as a SEPARATE commit 
AFTER A is validated. A ships and proves it boots + enforces first; B1 (shared FIPS grub task) 
comes after, on its own. The dup is kernel-tolerated, it can wait one build.

On the dropped first-boot oneshot / live-flip-late approach: fine, but it means "nothing runs 
under enforcing" now depends on the flip being genuinely the last step before InSpec. So the 
validation must prove nothing hardening-related runs after the flip, AND the SSH hard gate 
stands: getenforce=Enforcing, relabel done, zero AVCs against sshd/chronyd/clamav/nessus/cwa/ssm, 
and SSH actually connects with sshd reading 10-scs-hardening.conf. No SSH proof = not a pass.

Show me the real grub line, then proceed.
