SLES 16 (SCSEC-8697) Read-only status pass, change nothing.

1. Ram raised STIG MR !305. Read it. Tell me: does it add a SLES 16 STIG role, or only refactor the existing RHEL / SLES-15 roles into his new format? If it adds a sles16 path, how does harden.yml wire it in, and does that collide with my commented-out SLES-15 STIG block and version-guarded audit block on branch c5425849-sles16? I need to know if my harden.yml changes now need reconciling with his.

2. Across all four repos on branch c5425849-sles16, how far behind origin/main is each now that 202610A merged, and would a rebase conflict anywhere (sshd_config copy task and harden.yml are the likely spots)?

3. What's still test-only and must come out before any MR (the 3 collectd guards, the infra packer pointer 7656340, the test_c5425849_build.yml pointers) — give me the exact MR-ready commit set after cleanup, including the packer 5→1 squash.

4. Of the 8 InSpec failures from build #22, which are still open after the rebase, and what would the /usr/etc sudoers + logrotate fix look like in the inspec-image-tests repo.

Then propose an order of operations and I'll approve before anything moves. Don't touch STIG — that's Ram's; flag anything that needs a word with him or Steve.
