Approved on sudoers — apply the OS-adaptive test fix. One confirm first: ls -l /usr/etc/sudoers 
on a built 16 image so the assumption the file exists is proven, not inferred.

Logrotate — hold, don't draft the fix yet. Run the two read-only checks on a built 16 image 
first: ls -l /usr/etc/logrotate.conf (is there a vendor file to seed from), and 
systemctl list-timers | grep logrotate (does 16 ship a logrotate.timer). The timer answer 
decides the fix: if SLES 16 rotates via a systemd timer by default, the vendor-native fix is 
to NOT template our cron-hourly wrapper on 16 and let the timer handle it — not to seed 
/etc/logrotate.conf to prop up our old cron approach. Follow the vendor default here, same as 
we did for SELinux. Show me both check results + a recommendation before drafting anything.

Regression check looks solid — changes are properly 16-gated, no other OS affected, 
selinux-apparmor untouched. Note the two latent gaps for the ticket (enforce-flip only in 
aws hcl; Shoot/Nvidia-on-16 apparmor) — don't fix now, just so they're tracked.
