I'm verifying a fix for Jira STOI-13938 by booting a KVM golden image in SCI
OpenStack (region eu-de-1, project DEV_SEC_GOLDEN_IMAGE). My CLI is configured:
`openstack --os-cloud openstack_ext_dev ...` works.

Goal: boot image "C5425849-Golden-KVM-CDN2-SCS-RHEL-9.6-Base-100923" on flavor
g_k_c4_m16_v2 (KVM flavor, zero root disk so it must boot from a volume), SSH in
with key c5425849-kvmtest, and check /proc/cmdline and current_clocksource.

The blocker is volume creation. What I've tried, all failed:
- boot-from-volume via `server create`: volume goes to error, instance aborts.
- volume type `vmware` (the default), size 100: created then error.
- volume type `premium`, size 100: error.
- volume type `standard_hdd`, size 100: rejected, needs 500GB minimum.
Image virtual_size is 100GB. Quota is fine (4.5TB of 75TB, 24 of 10500 volumes).
Volume types available: premium, standard_hdd, vmware.

Please investigate WITHOUT creating lots of resources:
1. Figure out the correct volume type + size for booting a KVM image here.
   Look at how existing KVM servers in this project are backed:
   `openstack --os-cloud openstack_ext_dev server list`, pick a running
   Golden-KVM-* one, and inspect its attached volume's type/size with
   `server show` then `volume show`. Copy whatever the working KVM instances use.
2. Check the premium/standard_hdd error reasons if any detail is available.
3. Once you know the right type+size, create ONE volume from the image, confirm
   it reaches `available`, boot the server from it, attach a floating IP
   (external net: FloatingIP-external-iaas-01 or the shared one — match what
   existing floating IPs use), and SSH in.
4. Run: cat /proc/cmdline | grep -o clocksource=kvm-clock
        cat /sys/devices/system/clocksource/clocksource0/current_clocksource
5. Clean up after: delete the server, floating IP, and volume.

Use unique names (c5425849-kvmtest-<n>) so nothing collides. Show me the plan and
the working volume type before you create anything. Don't retry a failing type
more than once.
