SLES 16 (SCSEC-8697), roles branch c5425849-sles16. Build #11 now fails at:
  base: "Ensure Defaults secure_path is set in /etc/sudoers" → /etc/sudoers does not exist (rc 257)
in base/tasks/sudoers.yml (an OS-AGNOSTIC shared task, line ~44). This is a
security-sensitive, CODEOWNED, shared-across-every-OS task. Treat it with extra care.

THIS IS INVESTIGATION ONLY. Do NOT edit sudoers.yml or any sudoers-related file. Do
NOT commit, do NOT push, do NOT build. Read, analyze, recommend — then STOP and wait
for my explicit approval before changing anything.

PRIMARY QUESTION — how does SLES 15 (SP5/SP6/SP7) get PAST this exact task today?
Those builds work, so SLES 15 clearly satisfies this task somehow. Find out exactly how:
- Does /etc/sudoers exist on a built SLES 15 image at the point this task runs? If so,
  what puts it there — the base package set (sudo package ships it?), an earlier task,
  the AutoYaST profile, something in os/sles-15.yml?
- Does SLES 15 also have a /usr/etc/sudoers, or only /etc/sudoers? i.e. is the
  /usr/etc stateless split NEW in 16, or does 15 have it too and handle it differently?
- Walk the full ordering: what runs before base/tasks/sudoers.yml that might create or
  symlink /etc/sudoers on 15 but not on 16?

SECONDARY — the SLES 16 reality (read-only, off the built image / the Pool content):
- On SLES 16, is /etc/sudoers genuinely absent, a symlink to /usr/etc/sudoers, or
  copy-on-write? Confirm which — it changes the fix.
- What does the sudoers.d/01-secure-path drop-in (the same task writes it) actually
  deliver? Is secure_path already set via that drop-in regardless of the /etc/sudoers
  edit? If so, the /etc/sudoers lineinfile may be redundant on 16.
- Does the `sudo` package in the SLES 16 Pool repo ship /etc/sudoers or /usr/etc/sudoers?

THEN RECOMMEND (do not implement): lay out the options you see — e.g. (a) ensure the
sudo package / an early step provides /etc/sudoers on 16 the same way 15 gets it,
(b) point SLES 16 at /usr/etc/sudoers via an OS-gated branch, (c) rely on the
sudoers.d drop-in and guard the /etc/sudoers edit off for 16 — and tell me which is
LOWEST blast radius (ideally one that changes NOTHING for RHEL/Ubuntu/SLES 15). For
each option, state explicitly what other OSes it could affect.

CRITICAL: if any fix touches the shared sudoers.yml or any sudoers behavior, you must
ASK ME FIRST and get explicit approval before implementing. No commit, no push, no
build until I approve. A wrong change here can break sudo/privilege config on EVERY
image — so bias toward the smallest possible, most SLES-16-isolated change, and when
in doubt, ask rather than act.

REPORT: how SLES 15 satisfies this task today, the SLES 16 /etc/sudoers reality, what
the drop-in delivers, and your ranked options with blast radius each. Then hold for my
decision.
