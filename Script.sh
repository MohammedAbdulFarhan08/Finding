Timer answer settles it — drop the cron-hourly wrapper on SLES 16, let logrotate.timer handle 
rotation (vendor default, same principle as SELinux). Don't seed /etc/logrotate.conf.

But before drafting: cat /usr/etc/logrotate.conf and show me which directory it includes. This 
is the thing that actually matters — our /etc/logrotate.d/rsyslog rule caps /var/log/messages 
at 256 MB, and that cap only applies if the vendor config includes the directory our rule lives 
in. If the vendor file includes /etc/logrotate.d/, we're fine as-is. If it only includes 
/usr/etc/logrotate.d/, then just dropping the wrapper leaves our 256 MB cap dead — our rsyslog 
rule has to move to where the timer reads it. Confirm the include path, then draft both parts:
(1) roles: gate the cron-hourly logrotate template off SLES 16 (+ relocate the rsyslog cap file 
IF the include path requires it), and (2) inspec: make logrotate-config /usr/etc-aware for 16, 
same pattern as sudoers.

Show me the cat output + both drafts before applying. Also: the temp packer diagnostic 
(d574afc) is flagged remove-before-MR — make sure that comes out before these go up.
