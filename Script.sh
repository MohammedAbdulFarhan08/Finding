End-of-day context update, no action needed — just keeping you current for when we pick this back up.

OpenStack creds task (SCSEC-9044 / STOI-15367): TTU access request is raised and reviewed by Heather, now with Patryk for managerial approval. One prerequisite surfaced that gates the later CLI step (creating the app cred as the TTU), not just the ticket: SMS environment access needs a FIPS-enabled YubiKey — order via Ariba if not already held, checking with Steve. So all the credential/Vault/pipeline work stays held until the TTU is approved AND YubiKey access is sorted. Keep the doc draft and plan as-is; nothing to change.

ARM (SCSEC-8912, Ubuntu 24): John made big progress today — ARM build cluster is up, he ported the build from TCG emulation to native KVM (so builds are fast now, no more hour-plus emulated installs), and got repository-management working for ARM on the build cluster (that was the exact step the emulated RHEL/Ubuntu builds were dying at). But 8910 is NOT merged to main yet — John’s targeting Thursday for the ARM handoff (“by thursday i think its finally arm time”). So SCSEC-8912 stays held until 8910 lands; nothing to build before then.

One thing for Thursday: John set up ARM Vault paths under core-images/aarch64/ in kv_core_concourse (per-cloud: aws-commercial / azure / gcp testing, namespaced with his contractor number c5406745). When we start building, we copy his path structure and swap c5406745 → our c5425849. GCP is scaffolding only (no ARM instances) — real first target is aws-commercial.

Everything’s held pending approvals (creds) and the 8910 merge (ARM). We resume Thursday.
