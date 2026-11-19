Done — the technical-user credential is validated end-to-end. Ran the new TTU cred through a real openstack-kvm build (RHEL 8.10 Base): Keystone auth, Glance upload (image came up active, 4.7GB), Nova flavor/image/volume + server launch, and Barbican bootstrap all passed. The cred fully replaces the person-tied one in Vault (core-images/shared/openstack_ext_dev), John’s old cred kept for now as rollback.

Also wrote it up in documentation/infrastructure/openstack-tech-user.md — account details, setup steps, keypair registration, and how to rotate the cred. Holding the MR for it until the release goes out tomorrow.

A few bumps along the way: local repos were behind main (fixed with a pull); a stale upload_host IP in my pipeline (repointed to the DNS name); and the TTU needed its own Nova keypair registered. All resolved.
