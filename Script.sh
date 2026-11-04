Go with option (i) — rename our drop-in to syslog on SLES 16, override the vendor by filename. 
(ii) is out: no cross-file stanza override means keeping 'rsyslog' needs an empty shadow file 
to avoid the dup error, and that's a silent footgun if it's ever deleted. (i) uses SUSE's own 
/etc-overrides-/usr/etc mechanism, one authoritative capped rule, and matches what we already 
do on 15 (replace the vendor syslog). 

Apply A–D as drafted, strip the temp diagnostic (a990a48) in the same change, and run ONE 
validation build. Pass criteria: logrotate.timer runs clean (zero duplicate-entry errors), 
logrotate -d shows our 256M cap is the single effective rule for /var/log/messages, 
logrotate-no-syslog-conflicts green for the RIGHT reason (syslog present+capped on 16, still 
absent on 15), and logrotate-config green. If anything's off, stop and report — no reflexive 
rebuilds.
