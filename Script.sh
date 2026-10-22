Steve's good with the plan. Draft the fix on the c5425849-chrony branch, two parts:
1. Build-time: keep chrony.conf startable on Azure — no refclock (plain server/pool or
   sourcedir is fine), so the build doesn't hit the 2.9-000014 fatal.
2. First-boot runtime: apply the Azure PHC refclock when /dev/ptp0 exists, mirroring
   what chrony-configure-standalone.yml already does (append refclock + makestep 1.0 -1,
   preserve stock sourcedir /run/chrony-dhcp, restart chronyd). Read that playbook first
   and base the logic on it since it's proven on live Azure.

Use a baked systemd oneshot for the first-boot trigger unless you find the repo has an
established cloud-init pattern for this kind of thing — if so, flag it and I'll decide.
Show me the diff before committing. Don't raise an MR — MRs are held pending the release
flow.
