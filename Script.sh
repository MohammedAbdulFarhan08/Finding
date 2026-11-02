Good plan overall. Two amendments, then proceed on your own judgment — you don't need to 
gate every step on me. Work through it, and only stop if you hit a genuine fork or a decision 
you can't make from the context you have.

ONE hard stop though: the grub cmdline edit. Before you APPLY any change to 
GRUB_CMDLINE_LINUX_DEFAULT / base/tasks/grub.yml, show me the actual current line from the 
built image and the exact before/after diff, and wait for my ok. That's the one file where 
wrong = unbootable, so I want eyes on it. Everything else — packages, /etc/selinux/config, 
the first-boot oneshot, restorecon, the InSpec changes — just do it; the validation build 
will catch mistakes.

Amendments:
1. SPLIT grub dedup from the SELinux change — two separate diffs: Change A (SELinux enabling, 
   incl. adding selinux=1 idempotently) and Change B (the fips=1 dedup in shared grub.yml), so 
   if a build won't boot I know which one did it.
2. Make every cmdline edit idempotent for real (a when: or non-double-appending regexp, not a 
   comment) so nothing re-introduces a dup.

For Change B, spell out the ordering vs the FIPS playbook (it runs later and also writes both 
grub keys) so the dedup doesn't get undone, and say whether it's fragile if someone reorders 
playbooks later.

VALIDATION — SSH is a hard gate. The enforcing build must prove: getenforce=Enforcing; relabel 
done; zero AVC denials against sshd/chronyd/clamav/nessus/cwa/ssm; AND SSH actually connects 
with sshd able to read /etc/ssh/sshd_config.d/10-scs-hardening.conf. A mislabeled sshd drop-in 
under enforcing = lockout, which a passing InSpec would miss. No SSH proof = not a pass.

Build it. Stop only for the grub cmdline diff and any real fork.
