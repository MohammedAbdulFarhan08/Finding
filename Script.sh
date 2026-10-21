Time to start authoring the FIPS tasks for SLES 16. The research is done, the
harden.yml unblock is committed, and the direction is settled: model on SP6, create
the sles/16/sp0 task directory, and use vendor docs as the source of truth.

Key facts you already found:
- SLES 16 ships GRUB 2.12 (not systemd-boot), so grub tasks carry over
- fips-mode-setup exists on 16, which might simplify the enable task vs SP6's
  hand-rolled sequence
- libopenssl-3-fips-provider is the right FIPS package, same as SP6
- No official SLES 16 FIPS guide exists yet, so we're working from SP7 docs + Leap
  16 package evidence

What I need:
Build the check, enable, and disable FIPS task files for SLES 16 under
sles/16/sp0/. Use the SP6 tasks as your starting point, but don't blindly copy —
cross-check against the SUSE vendor docs and the actual 16 package names to make
sure everything is correct for 16. If something looks different or uncertain, flag
it rather than guessing.

Also do a broader check from your side — if there's anything else in the fips role
that assumes SLES 15 behavior or needs adjusting for 16 (vars, defaults, conditionals,
templates), call it out. I'd rather catch it now than on a failed build.

Show me the full diff before committing. Nothing gets pushed without my review.
