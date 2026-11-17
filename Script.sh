Nessus arm64 status (affects the metal build’s gate):

The bare-metal Ubuntu ARM build pulls the Nessus agent from the same S3 bucket as every other build — sap-core-images-binaries/packages/tenable/ — via the unconditional provisioner in golden.pkr.hcl. That bucket currently has only amd64 Nessus packages; the arm64 .deb doesn’t exist there yet. So the metal build will 404 at the Nessus step until it’s uploaded — same blocker as the commercial Ubuntu Base build.

The file needed is NessusAgent-10.9.0-ubuntu1604_aarch64.deb (version 10.9.0 to match the amd64 pin, uploaded flat into packages/tenable/). It’s tracked under SCSEC-9168, now with Steve.

Why it’s not done yet: Tenable’s public download only offers the current agent (11.2.3), which is newer than our Nessus manager (10.12.5) and wouldn’t register. The 10.9.0 arm64 build is behind a Tenable login (Ram has none), so Steve is handling it with his login. Steve has said to hold till the December release (he kicks it off tomorrow morning), so the upload lands then.

Bottom line for the metal branch: the role-side nessus fix (arch-conditional _amd64→_aarch64 suffix) is already carried in the cherry-picked commits — no code change needed. The build is staged and correct; it just can’t trigger a green run until that .deb is in the bucket. So: stay staged, do NOT trigger, wait for the nessus upload.
