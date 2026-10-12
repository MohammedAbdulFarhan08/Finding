Strict rules from here on:
- Do not delete anything without asking me first: servers, volumes (including
  error ones), floating IPs, keypairs, security groups or attachments. List
  what you'd remove and wait for my yes.
- Apart from the probe and the single server described below, don't create
  anything.

Probe: yes, run a bounded one. Create one image-backed premium volume from the
RHEL 9.6 image every ~20 minutes, max 6 attempts, with unique names. Stop at
the first success. Leave failed volumes in place and list them for me.

On first success: keep the volume (delete_on_termination=false) and boot ONE
server from it in eu-de-1d with flavor g_k_c4_m16_v2, network
DEV_SEC_GOLDEN_IMAGE_private, key c5425849-kvmtest, and security groups
images-team-ssh plus c5406745-ssh. Attach floating IP 139.66.27.63.

Before SSH: read the console log and compare the key fingerprint cloud-init
installed for cloud-user with my local key
(ssh-keygen -E md5 -lf ~/.ssh/c5425849-kvmtest.pub). Don't assume a fresh boot
fixes it. If they differ, stop and tell me.

If SSH works, run the two clocksource checks, show me the output, then STOP and
leave everything running. Don't tear anything down.
