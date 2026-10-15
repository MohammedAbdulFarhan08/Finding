APPROVED — proceed. Do these in order.

1) REBASE FIRST — main moved. Steve just merged his changes into main, and our
   branch c5425849-sles16 was cut from main. Before any build, rebase the branch
   onto latest main.
   - Resolve conflicts carefully — do NOT drop or overwrite Steve's changes.
   - Watch two files especially:
     • the four golden.pkr.hcl files — we added http_content lines; if Steve
       touched them, keep BOTH sides.
     • the base ansible role's grub_kernel_opts map — that's our Gate-A dependency.
       If Steve changed it, re-verify net.ifnames=0 biosdevname=0 console=ttyS0
       are still applied for SUSE and grub still regenerates.
   - The local tree is what `pt --code-prefix` builds from, so rebase locally, then
     force-push the feature branch to keep the remote current (it's my own branch,
     safe to force-push).
   - Report what the rebase pulled in and any conflicts you resolved BEFORE building.

2) NETWORKING — approved as you proposed: #1 then #2, #3 stays in reserve.
   - Try #1 (inst.copy_network=1) as a SINGLE cheap probe — one token on the
     boot_command linux line. On the next VNC check, if eth0 still has no IP, do
     NOT debug it — fall straight to #2.
   - #2 (NetworkManager .nmconnection keyfile, ipv4.method=auto) is the real fix
     and it's native: SLES 16 defaults to NetworkManager (wicked is gone). Confirm
     NM is the active stack on the booted image, add the keyfile via the profile
     post-script, and ensure NM is installed + enabled. Still pure-XML.
   - Do NOT switch the profile to Agama JSON (#3) for networking. Networking is
     solvable in XML; #3 stays shelved.

3) SCOPE CONFIRMATION — do this now, it's cheap:
   - List every file you've modified on c5425849-sles16 vs main.
   - Confirm you did NOT touch: any SP7 file (sles-15.7 pkrvars or sles15-SP7.xml),
     any InSpec test/check, main directly, or pre-release Vault secrets.
   - SP7 is out of scope and stays exactly as-is — we only derive from it, never
     edit it.

GATES / DONE:
- CREATE-green = install completes, eth0 has an IP, Packer SSHs in. That proves the
  boot_command + networking. Stop there and report.
- Not ticket-done, but Gate A already closed (base role carries the kernel args), so
  once networking's fixed the ONLY SP7 deviation left is the add-on removal + the
  DHCP connection. Keep it that clean.

HARD RULES (unchanged): branch c5425849-sles16 only, never main; never edit an
InSpec test to pass a build; never modify pre-release Vault (copy only); OpenStack
act by resource ID.

CHECKPOINT: ping me at CREATE-green with (a) the networking result (#1 or #2, and
whether eth0 came up) and (b) the scope changelist. Hold there — we'll clean up the
MR commit history before John sees it.
