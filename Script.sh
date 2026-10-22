New priority ticket STOI-14182 — production bug on Azure RHEL 9.6 HANA and Sapapp
golden images. Time sync is broken. Prioritized over SLES 16 work.

Ticket details:
- Affected images: Golden-SCS-RHEL-9.6-HANA-V2026-04-16-1527 and
  Golden-SCS-RHEL-9.6-SAPAPP-V2026-04-16-1527
- Platform: Azure Government, Commercial Regulated (CRE)
- Bug: /etc/chrony.conf is missing NTP configuration. "chronyc sources -v" returns
  empty. Missing lines:
    refclock PHC /dev/ptp0 poll 3 dpoll -2 offset 0
    makestep 1.0 -1
    sourcedir /run/chrony-dhcp
- Reporter says chrony-configure-standalone.yml in shared/ansible/playbooks fixes it
  manually
- Environment: Dev, PreProd, Stage, Production — all affected

READ-ONLY investigation. Read from origin/main — don't create any branches or edit
any files yet. I need to understand:

1. How does chrony get configured in our golden image build pipeline? Find the chrony
   role or chrony tasks in the roles and playbooks repos. What does the build write to
   /etc/chrony.conf, and is it cloud-provider aware (AWS vs Azure vs GCP)?

2. Read chrony-configure-standalone.yml in shared/ansible/playbooks — the reporter
   says this fixes it. What does it do differently from the build pipeline? Why would
   it work as a manual fix but not be in the build?

3. Why Azure specifically? Azure uses /dev/ptp0 as the hypervisor time source, not
   the AWS 169.254.169.123 NTP endpoint. Is the build pipeline handling this
   difference?

4. Is there anything HANA/SAP-specific in the chrony setup that could explain why
   these particular images are affected?

Give me root cause, blast radius (which other images might have the same issue), and
the fix shape before I touch anything.
