I'm prepping for a planning call with Steve and Ram about standing up DISA STIG +
FIPS hardening for SLES 16 (ticket SCSEC-8697, my branch c5425849-sles16). This is
the hard stop on the SLES 16 enablement — everything up to FIPS is done and
validated; STIG and FIPS are security-sensitive so I'm NOT writing them solo, I'm
gathering facts for the call.

This task is READ-ONLY. Do not edit, create, commit, or push anything. Just read the
repos and give me a briefing. The repos are in my feature tree ~/c5425849-sles16
(rebased on main) — read the current state there.

Investigate and report on:

1. STIG role structure. Read the existing *-disa-stig roles in ansible/roles,
   especially rhel10-disa-stig (the newest new-OS example) and sles15-disa-stig (the
   SUSE one). For each: how the role is laid out (tasks/vars/templates), how it's
   gated and invoked from harden.yml, where the control definitions come from
   (benchmark / SSG XML / vars), and how EXEMPTIONS.md is structured — show me what a
   disabled control entry looks like and the stated reason.

2. Where SLES 16 breaks today. Find and QUOTE the gate in harden.yml that currently
   runs sles15-disa-stig on SLES 16 (os_family-based, around line 272). Confirm no
   sles16-disa-stig role exists. Tell me the minimal shape a sles16-disa-stig role
   would need to exist and be wired in — do NOT write it, just describe the shape.

3. FIPS role. Read the fips role. How does it do FIPS for RHEL vs SLES 15? Find and
   QUOTE the path logic that builds a sles/16/sp0 path that doesn't exist. SLES 16
   uses the OpenSSL-3 provider FIPS model (libopenssl-3-fips-provider /
   patterns-base-fips) rather than the SP-style layout — point out exactly what in
   the role assumes the old SP model and would have to change.

4. STIG source-of-truth gap. DISA has NOT published a STIG for SLES 16 (only 12 and
   15). Check whether the repo's SUSE STIG content keys off a DISA benchmark / SSG
   XML or the GPOS SRG. Then lay out the options to take to Ram — adapt the SLES 15
   controls to 16, harden against the GPOS SRG, or wait for DISA — and what each
   would mean concretely in this codebase.

Output: a concise briefing with exact file paths, the quoted gates/path logic, a gap
list, and the open questions for Steve and Ram. No code changes, no proposals to
implement — reconnaissance only.
