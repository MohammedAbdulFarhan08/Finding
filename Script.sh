The ARM (aarch64) golden image builds for all three Linux OSes need the Nessus agent arm64 package, which isn’t in our S3 mirror. sap-core-images-binaries/packages/tenable/ currently holds only amd64 agents.

Needed — three arm64 files, all version 10.9.0 (to match the amd64 pin), all uploaded flat to packages/tenable/ (commercial bucket):

Ubuntu: NessusAgent-10.9.0-ubuntu1604_aarch64.deb
RHEL: NessusAgent-10.9.0-el10.aarch64.rpm
SLES: NessusAgent-10.9.0-suse15.aarch64.rpm

Confirm each exact filename against Tenable’s real arm64 artifacts on upload (arch token / distro suffix may differ) so the roles resolve.
