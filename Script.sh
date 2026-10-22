Confirm build-time startability for the chrony fix — this is the one thing that gates
the fix design before I write any template change.

The question: on an Azure QEMU build, if the chrony template bakes in the refclock
(refclock PHC /dev/ptp0 ...) plus sourcedir /run/chrony-dhcp, does chronyd start
cleanly even though /dev/ptp0 doesn't exist in the QEMU environment? The chrony role's
restart handler is a bare "state: restarted" that will fail the whole build if chronyd
won't come up. That exact failure mode is why the Azure refclock was gated off in the
first place (changelog 2.9-000014, "Azure NTP source breaks QEMU builds"), so I need
to know we won't recreate it.

Figure out:
1. Does chronyd tolerate a missing refclock device at startup (warn + continue), or
   does it hard-fail? Check chrony's actual behavior with a non-existent PHC device
   plus a valid sourcedir fallback. If you can verify it in a real QEMU build rather
   than just reasoning about it, do that — a live confirmation is worth more here than
   docs since this is production time sync.
2. If there's any risk it hard-fails, what's the safe shape — rely on sourcedir
   /run/chrony-dhcp as the startable source, make the restart handler tolerant, or
   something else — so the build stays green while the refclock is still baked for
   runtime.

Also, separately: who introduced the 2.9-000014 change and when? Check the git blame /
commit history and CHANGELOG-SCS.md for that entry — I want the author and the commit
message so I can loop them in if needed, since they hit this QEMU-vs-Azure problem
before and may have context on what they tried.

Read-only — don't write the fix yet. Report startability findings + the 2.9-000014
author, then we'll plan the template change.
