Grab it — cat /usr/lib/systemd/system/logrotate.service (and the ExecStart specifically) on 
the next build. That line decides the whole fix, so no drafting until we have it. Keep the 
inspec /usr/etc-aware test fix held too — I don't want logrotate-config green while the cap 
might be dead.

Once you have ExecStart, draft the full fix for my review, which needs to guarantee BOTH:
(1) our /var/log/messages 256 MB cap is actually read by whatever the timer runs, and 
(2) the vendor's loose /usr/etc/logrotate.d/syslog (size +4096k / rotate 99 / maxage 365) 
doesn't double-cover or override our cap — same neutralize-the-vendor-loose-syslog logic our 
logrotate-no-syslog-conflicts control already does for /etc.

Only turn the inspec control green once the cap is provably in effect, not just once the file 
exists where the test looks. And strip the temp diagnostic (73dff31) before any of this goes 
to MR.
