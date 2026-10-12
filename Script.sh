Full context update for STOI-13938 (KVM clocksource ticket). Stop any probe loop.

WHAT'S DONE:
- Fix is written, committed, pushed on branch c5425849-kvmcloak in the ansible
  roles repo: one idempotent task in base/tasks/main.yml appending
  clocksource=kvm-clock to grub_kernel_opts, gated on
  image_cloud_partition == 'openstack_kvm', plus a CHANGELOG-SCS.md bump.
- Built green on the openstack-kvm-testing-c5425849 pipeline (roles ref 7774e4c).
- VERIFIED on a live RHEL 9.6 KVM instance today: /proc/cmdline contains
  clocksource=kvm-clock AND /sys/.../current_clocksource reads kvm-clock.
  No "time jumped backwards" in journald. STOI-13938 core fix is proven for RHEL.

THE WORKING BOOT RECIPE (from John), KVM images only:
openstack --os-cloud openstack_ext_dev server create \
  --flavor g_k_c4_m16_v2 \
  --block-device uuid=<IMAGE_ID>,source_type=image,destination_type=volume,volume_size=100,volume_type=premium,boot_index=0,delete_on_termination=true \
  --network DEV_SEC_GOLDEN_IMAGE_private \
  --key-name core-images-image-creation \
  --security-group images-team-ssh \
  --security-group c5406745-ssh \
  <SERVER_NAME>
- SSH key: the shared core key core-images-image-creation (NOT my own keypair).
  SSH as cloud-user with that key.
- VPN: Cisco Secure Client AND GlobalProtect (US Central) both connected.
- Known issue: the premium volume backend is intermittent. If volume creation
  fails with "no available weighted backend", it's a backend outage, not the
  command. Wait and retry, don't change the command.

WHAT'S NEXT (John's plan):
- Keep the fix on all RHEL (done, verified).
- Boot SLES (cHost variant, no base on KVM) and check whether it even needs the
  arg. SLES uses grub2-mkconfig, different from RHEL's grubby/BLS path.
- Boot Ubuntu (base) and check whether it needs the arg.
- To decide need: pull the vendor docs (SUSE, Ubuntu) on default clocksource for
  KVM guests. John's tip: curl the docs, grab markdown if it exists, else curl
  HTML and convert with pandoc. Reason from real docs, not guesses.
- Then write the InSpec control in inspec-image-tests, modeled on MRs !245/!75.

RULES:
- Do not delete anything (servers, volumes, floating IPs, keypairs, SGs,
  attachments) without asking me first.
- Only create what a given step needs; no probe loops.





KVM base builds are failing an existing InSpec control (not mine):
active-initramfs-present — "ls /boot/initramfs-*.img" returns empty after cleanup,
exit 100. 

Key pattern: RHEL 9.6 and 9.8 PASS. RHEL 10.2, Ubuntu 22.04/24.04, and SLES FAIL.

My change (clocksource=kvm-clock appended to grub_kernel_opts, gated on
image_cloud_partition == 'openstack_kvm', no OS condition) applies identically to
ALL of them — so it can't explain why only some fail. 9.6 with my fix also booted
fine on a live VM with a working initramfs.

Investigate — don't change anything, just diagnose:
1. Confirm my reasoning: since 9.6/9.8 carry the same fix and pass, is my change
   ruled out? 
2. Find a build of RHEL 10.2 / Ubuntu / SLES WITHOUT my commit (on main, e.g. an
   earlier baseline) and check if it ALSO fails active-initramfs-present. That
   tells us if this is pre-existing.
3. Look at what the active-initramfs-present control actually checks, and why it
   would pass on RHEL 9.x but fail on 10.2/Ubuntu/SLES. Does the initramfs get a
   different filename or path on those OSes (e.g. Ubuntu uses initrd.img-*, not
   initramfs-*.img)? Read the control's source in inspec-image-tests.
4. Report: is this my fix, a pre-existing control bug, or a real initramfs
   problem on those OSes?
