Context: SCSEC-8697, SLES 16 enablement. InSpec on the latest SLES 16 build (#25, or newer if 
the rebased validation build has finished) fails the apparmor-status control. SLES 16 is 
believed to ship SELinux by default instead of AppArmor. Before I ask Steve for a decision I 
need the facts nailed down. Read-only: NO builds, commits, or pushes. Evidence for every 
claim; if something can't be confirmed from the repo or build output, say so instead of 
assuming.

1. THE CONTROL: in inspec-image-tests, find the apparmor-status control. Give the file path, 
   exactly what it asserts (package installed? service active? profiles loaded/enforcing?), 
   and how it's gated per OS (is there any SLES 15 vs 16 conditional today?). Quote the exact 
   failure message from the SLES 16 InSpec output.

2. WHAT SLES 16 ACTUALLY HAS: from the build logs / InSpec output / package lists / Agama 
   profile for the SLES 16 image, determine: is SELinux installed, and in what mode 
   (enforcing / permissive / disabled)? Is AppArmor absent or just inactive? If the build 
   artifacts can't show this, say what would (e.g. a getenforce / sestatus check on a booted 
   image) rather than guessing.

3. HOW OUR ROLES TREAT IT: in the roles repo, how is AppArmor handled for SLES 15 (installed / 
   enabled by a role?), and is there anything on 16 for SELinux or AppArmor (tasks, 
   harden.yml guards, FIPS/STIG roles that assume one or the other)? List every file/line.

4. EXISTING PATTERN: does inspec-image-tests already have an SELinux control for RHEL? Show 
   it, since that's the pattern to reuse if we add one for SLES 16.

5. STIG/SSG CONTENT: if any SLES 16 STIG / SCAP / OpenSCAP profile content exists in the repos, 
   does it require SELinux or AppArmor on SLES 16? If it isn't in the repos, say 
   "not determinable here".

6. OPTIONS, no changes made: describe (a) adding a SELinux check for 16 (exact files and 
   rough size of change) and (b) skipping the apparmor control on 16 (how exemptions or OS 
   gating are done elsewhere in this repo, with an example). Give a recommendation with 
   reasoning, and flag any risk in either.

Summary at the end: one paragraph I can use to ask my team lead for a decision.
