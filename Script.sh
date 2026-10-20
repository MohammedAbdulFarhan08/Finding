APPROVED — apply the existence-guard. Verification closed the no-network risk (the
mid-build reboot proved eth0 DHCP survives with no ifcfg) and the grep showed no
downstream dependency. Proceed.

CHANGE: in base/tasks/networking.yml, existence-guard the "Ensure ifcfg-eth0 exists for
SLES" task — stat /etc/sysconfig/network (register once), add `<stat>.stat.exists` to
the existing `when: ansible_os_family == 'Suse'`. Skip when absent. Do NOT touch the
Azure/RHEL tasks or any other OS. Minimal diff, 16-scoped.

BEFORE BUILD: force-check the roles git resource, confirm it has the new commit (build
#12 stale-code lesson). If a prior build failed, confirm it wasn't a Vault/secrets error.

VALIDATE (aws-com): expect play past ok=258 toward the DISA/STIG role. Name where it
stops precisely.

CRON SERVICE — now that a build should finalize an image, verify cron is enabled+active
on the built 16 image (systemctl is-enabled/is-active) and /etc/cron.hourly/logrotate
present. If NOT enabled, flag it — do NOT add an enable task without asking.

HARD STOP: DISA/STIG role → do not author, capture + report (Steve + Ram call).
HARD RULES: branch c5425849-sles16 only; never main; never edit InSpec; CODEOWNED roles
repo — minimal diff; OpenStack by ID. MR held.

REPORT: the one-task diff, where the build stops, and the cron service state. Then hold.
