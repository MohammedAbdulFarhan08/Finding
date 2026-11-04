Logrotate fix — I have the vendor logrotate-all script behavior confirmed from SUSE/openSUSE 
public sources, so NO more discovery builds. Draft the complete fix now, all parts together, 
then ONE validation build. Read-only until I approve the drafts.

Confirmed behavior of /usr/sbin/logrotate-all (what logrotate.service/timer runs on SLES 16):
- It builds a config list itself: reads /etc/logrotate.conf (or /usr/etc/logrotate.conf if 
  /etc absent), THEN includes BOTH /usr/etc/logrotate.d/ AND /etc/logrotate.d/, with /etc 
  OVERRIDING /usr/etc BY FILENAME (same-named file in /etc wins; different names = both read).
- CRITICAL: because logrotate-all assembles the list itself, any "include /etc/logrotate.d" 
  line in a logrotate.conf causes a DUPLICATE-ENTRY error that breaks rotation for every file 
  in logrotate.d. So we must NOT add any include directive.
- /usr/etc is package-owned, never edit it; all our changes live in /etc/logrotate.d/.

Implications to build the fix around:
1. Our /etc/logrotate.d/rsyslog 256MB cap on /var/log/messages IS read by logrotate-all (it 
   includes /etc/logrotate.d). Good — the cap is alive.
2. BUT the vendor ships /usr/etc/logrotate.d/syslog (loose: size +4096k / rotate 99 / maxage 
   365) which also covers /var/log/messages. Our file is named 'rsyslog', vendor's is 'syslog' 
   — different names, so /etc does NOT override /usr/etc, and BOTH rules hit /var/log/messages 
   = double coverage / conflict (the thing logrotate-no-syslog-conflicts exists to catch).

Draft all parts:
A. roles/base: gate the /etc/cron.hourly/logrotate wrapper template OFF SLES 16 (let the 
   timer's logrotate-all handle it). Confirm no other OS loses its wrapper.
B. roles/base: neutralize the vendor /var/log/messages double-coverage. Recommend the cleaner 
   of: (i) rename our drop-in to 'syslog' so /etc cleanly overrides /usr/etc/logrotate.d/syslog 
   by filename, OR (ii) keep 'rsyslog' and explicitly override the vendor's /var/log/messages 
   stanza. Tell me which is safer and why — I want exactly ONE rule governing /var/log/messages 
   with our 256MB cap, no vendor loose rule double-covering it. Check our existing 
   logrotate-no-syslog-conflicts logic so this change is consistent with it.
C. GUARD: grep the whole repo (all OSes) for any 'include /etc/logrotate.d' or 'include 
   logrotate.d' we write into any logrotate.conf — on SLES 16 that breaks rotation. Confirm we 
   add none, on any OS.
D. inspec: make logrotate-config /usr/etc-aware for SLES 16 (same pattern as the sudoers fix), 
   AND assert the end state we actually want: /var/log/messages governed by our 256MB cap with 
   NO competing vendor rule. Don't just check a file exists — check the cap is the effective 
   rule. Keep SLES 15/RHEL/Ubuntu assertions byte-identical.
E. Regression: confirm A–D are SLES-16-gated and change nothing for other OSes.

Then I approve, you apply, and run ONE validation build that proves: logrotate.timer runs 
clean (no duplicate-entry errors), logrotate -d shows our 256MB cap is the winning rule for 
/var/log/messages, and the inspec control is green for the RIGHT reason. Also strip the temp 
diagnostic (a990a48) before MR.

Show me A–E as drafts first.
