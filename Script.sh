Context: SCSEC-8697, SLES 16. Steve (team lead) decided: follow SUSE's vendor default for 
the MAC framework. SUSE's position, per SUSE's own SLES 16 docs/blogs: SELinux replaces 
AppArmor, ships ENFORCING by default in plain SLES 16 with the targeted policy, and PERMISSIVE 
in the SLES for SAP variant. (Sources: suse.com/c/what-is-new-in-suse-linux-enterprise-server-16-0 
and suse.com/c/sle-16-and-the-public-cloud. Verify against SUSE docs if you can reach them; 
if not, say you couldn't.) 

STRICT RULES: read-only. Do NOT commit, push, edit any file, or trigger any build. Everything 
below is investigation plus DRAFTS shown as text for my approval. Evidence for every claim; 
if something can't be confirmed from the repos or build output, say so rather than assuming.

1. WHICH PRODUCT(S): which SLES 16 variants do our images target: plain SLES, SLES for SAP, 
   or both (check the pkrvars/image-lists/roles for any SAP-specific variant)? This matters 
   because vendor default is enforcing for plain and permissive for SAP, so a single 
   "assert enforcing" check could be wrong for SAP images.

2. WHAT THE IMAGE ACTUALLY HAS (the unknown): the earlier report couldn't tell if 
   selinux-policy / policycoreutils are installed on the final image or what mode it boots in. 
   Check what we can from the Agama profile, package patterns, and build #26 logs. Then DRAFT 
   (do not apply) a small read-only diagnostic to run on the booted instance during the 
   InSpec stage, modeled on the device-node debug dump we used for the NVIDIA work: print 
   getenforce, sestatus, rpm -q selinux-policy-targeted selinux-policy policycoreutils, 
   /etc/selinux/config, and the kernel cmdline (security=/selinux= args). Also include an AVC 
   denial check (ausearch -m avc -ts boot, or journalctl equivalent) so we can see whether 
   enforcing is already blocking any of our agents. Show me exactly where it would hook in and 
   how it would be output.

3. AGENT RISK: if the image is or becomes enforcing, list the agents/services we install on 
   16 that could hit SELinux denials (nessus-agent, clamav, aws-cloudwatch-agent, chrony, 
   sshd drop-ins, FIPS-related), and what in the repo already accounts for SELinux, if anything.

4. INSPEC CHANGE (draft only): 
   (a) gate apparmor-status off SLES 16, and confirm what os.release actually returns on SLES 
       16 under InSpec (is start_with?('16') correct?). 
   (b) draft the SELinux control for 16 modeled on the existing RHEL selinux-state control. 
       Propose what it should assert (getenforce exit 0 only, vs enforcing) and how to handle 
       the SAP/permissive case, but do NOT assume enforcing until step 2 evidence exists.

5. ROLE WORK, IF NEEDED: if step 2 shows the image is NOT enforcing (policy missing or 
   permissive), describe what a roles change would involve to match the vendor default 
   (install policy, set enforcing, relabel/first-boot considerations), as an outline only.

Finish with: what's confirmed, what's still unknown, and the smallest next action you'd 
recommend. Wait for my approval before touching anything.
