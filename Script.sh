I'm working on Jira ticket STOI-13938 for the SAP Security Golden Images team.
Work only in this repo (ansible roles), on branch c5425849-kvmcloak. Don't change
anything yet — investigate and report first.

Problem: our KVM golden images default the guest kernel clocksource to `tsc`
instead of `kvm-clock`. tsc isn't VM-aware, so when the hypervisor migrates,
pauses or resumes the VM the guest clock jumps backwards. journald floods with
"Time jumped backwards, rotating" and the OS eventually becomes unresponsive and
needs a hard reboot. The manual workaround was:
  sudo grubby --update-kernel=ALL --args="clocksource=kvm-clock"

Scope (already decided): all RHEL on the openstack_kvm partition
(RHEL 8.10, 9.6, 9.8, 10.2). Scope by partition, not per-version.

The packer file packer/openstack/golden.pkr.hcl runs base-configure.yml and
passes extra vars including base_cloud_provider and image_cloud_partition. KVM
images use the openstack_kvm partition value.

Please investigate and report (no edits):
1. Where does this repo currently set kernel boot arguments? Look for grubby,
   GRUB_CMDLINE_LINUX, /etc/default/grub, and how the fips role sets its kernel
   args. Show me the files and tasks.
2. What's the exact value of image_cloud_partition for KVM? Grep for
   openstack_kvm and confirm the spelling.
3. Which role/task is the right place to add a kernel-arg default scoped to the
   KVM partition? Propose a location and explain why.
4. Does the chrony role in this repo sync the guest clock to the host anywhere
   (ptp_kvm, PHC refclock, guest agent)? Does any other cloud do that?
5. How would you verify the fix (e.g. an InSpec check that /proc/cmdline contains
   clocksource=kvm-clock)?

Give me your findings and a recommended approach. I'll review before you write code.
