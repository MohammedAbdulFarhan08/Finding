Agreed — the timeline and the named cipher/ssh_set_newkeys mechanism are convincing, and it fits #22-green-on-old-hosts vs #23/#24-hang-on-new-FIPS-hosts. Retract the Steve message, this isn't a mirror gap.

Go ahead: force-push packer ed1c2d3 (with lease, remote at bda2173), re-check the packer resource, and re-trigger (#25). This is now the real test of the cipher-pinning fix.

If #25 clears the reboot and reaches FIPS/harden/InSpec — great, that also banks the #1/#2 clears, report the InSpec result. If it STILL hangs at the same reboot/reconnect, stop and capture the hung VM console before anything else, because then the pinning wasn't the whole story. Either way, don't do the roles/playbooks/infra rebases until #25's reboot result is in — one variable at a time.
