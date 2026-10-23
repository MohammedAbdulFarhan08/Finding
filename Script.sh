Ready for the Gov/CRE verification — I have Azure Gov/CRE deploy access. The 9.6 HANA
golden image is already built on the c5425849-chrony branch. This is a deploy-and-boot
test, not a pipeline build.

Walk me through / set up: deploy a VM from the 9.6 HANA golden image on Azure Gov/CRE,
boot it, then verify inside the VM:
1. the first-boot oneshot (chrony-azure-phc.service) ran — check systemctl status and
   the journal
2. /etc/chrony.conf ends up with refclock PHC /dev/ptp0, makestep 1.0 -1, and
   sourcedir /run/chrony-dhcp
3. chronyc sources -v is populated (not empty — that was the reported symptom)

Give me the exact deploy commands and the in-VM verify commands. Confirm which Gov/CRE
image identifier / resource group to deploy from first — don't guess it.
