Context: SCSEC-8697, SLES 16. Decision made (team lead): follow SUSE's vendor default = 
SELinux enforcing. The diagnostic on build #27 confirmed the 16 chost image currently has NO 
active MAC — selinux-policy-targeted / policycoreutils NOT installed, no /etc/selinux/config, 
no selinux=1 on the kernel cmdline, AppArmor absent. So this is the enabling role work, not an 
InSpec tweak.

STRICT RULES: read-only to start. Do NOT edit files, commit, push, or trigger a build. 
Everything below is investigation + DRAFTS shown as text for my approval. Evidence for every 
claim; if something isn't confirmable from the repo/build output, say so.

Goal: make SLES 16 boot SELinux enforcing with the targeted policy, SAFELY — without breaking 
build-time provisioning and without fighting the existing FIPS grub edit.

1. SAFE SEQUENCING (this is the core requirement): enabling SELinux from an unlabeled 
   filesystem mid-build risks AVC denials breaking provisioning. The intended pattern is: 
   install policy + set config to PERMISSIVE during the build, touch /.autorelabel, and switch 
   to ENFORCING on first boot (post-relabel). Confirm this is sound for our Agama/packer flow 
   and draft it that way. Flag if anything in our build would still run after SELinux is active 
   and could hit denials.

2. PACKAGES: draft adding selinux-policy-targeted + policycoreutils (+ policycoreutils-python-utils 
   if needed for semanage/restorecon) to base/vars/os/sles-16.yml base_os_package_list. Confirm 
   all are present on the 16 Pool first.

3. CONFIG + KERNEL CMDLINE: draft /etc/selinux/config (SELINUX=permissive→enforcing-on-first-boot, 
   SELINUXTYPE=targeted) and the kernel cmdline change to add selinux=1 security=selinux. 
   CRITICAL: show me exactly where our existing FIPS grub edit (fips=1) is applied — the #27 
   diagnostic showed fips=1 is ALREADY being DUPLICATED on the cmdline, so our grub handling has 
   a bug. The selinux args must go through the SAME mechanism, coordinated, so we don't double 
   args again. Draft the grub change to (a) add the selinux args once and (b) fix the fips=1 
   duplication while we're in there. Show the before/after cmdline.

4. FIRST-BOOT ENFORCING: draft the mechanism that flips permissive→enforcing after the 
   first-boot relabel completes (and only if relabel succeeded). Show where it hooks in.

5. ROLE PLACEMENT: should this live in base (os/sles-16.yml) or the existing selinux-apparmor 
   role? Note: that shared role currently only does SUSE=AppArmor and is invoked by the 
   Shoot/Nvidia presets with apparmor_state: enable — do NOT entangle this chost SELinux work 
   with that broken preset path. Recommend the cleanest placement.

6. INSPEC: draft (a) gating apparmor-status off SLES 16 (os.release confirmed "16.0", so 
   start_with?('16') is valid), and (b) a SELinux control for 16 modeled on the RHEL 
   selinux-state control — now it CAN assert enforcing, since that's the target end state.

7. AGENT RISK: list which of our 16 agents (nessus-agent, clamav, aws-cloudwatch-agent, 
   aws-ssm-agent, chrony, sshd) are most likely to hit AVC denials under enforcing targeted 
   policy, and whether the targeted policy covers them by default or we'll need custom contexts. 
   This is the thing most likely to surface on the validation build.

Finish with: the full ordered change set as drafts, what's confirmed vs assumed, and the 
validation plan (what the post-build diagnostic should check: getenforce=Enforcing, relabel 
completed, zero AVC denials against our agents). Wait for my approval before touching anything.
