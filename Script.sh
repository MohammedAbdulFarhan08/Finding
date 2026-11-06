Proceed with 1-3, then re-run the fan-out — don’t stop for my review first; the base result’s already validated and 1-3 are the same pattern on sibling presets. Still no MR; feature-push only, hold for my approval.

hana/sapapp presets: mirror the full base change onto the hana and sapapp RHEL presets (8/9/10) — MS-prod enable + EPEL excludepkgs=azure-cli + MS-prod includepkgs=azure-cli + the Microsoft GPG key render. Not just the repo enable, or they’ll hit the same gpgcheck failure base did.
CDN1 parity: apply the same MS-prod addition to the cdn1.yml base-preset override, and verify CDN1 serves the MS GPG key at the sapns2 path (matters for the gov/NS2 consumers on CDN1).
InSpec: add the “must be MS-repo rpm” assertion, keyed on rpm -qf $(which az) showing from_repo=packages-microsoft-com-prod and version ≥2.92 — not Vendor (the MS rpm’s Vendor is (none)). This is the recurrence guard; make it fail the build if az is EPEL-owned or a pip copy.

Coverage — don’t validate 9.6 only. Re-run the full 9.6 fan-out (base + hana + sapapp) with a boot test, verifying rpm -qf = MS-prod / ≥2.92 / gpgcheck passing on each. Additionally, for RHEL 8 and 10, at least run a dnf resolve/dry-run on the branch to confirm the MS-prod azure-cli rpm + full dependency closure resolves from the CDN2 mirror — 10 was never confirmed to have an el10 rpm on the mirror, and I don’t want that surfacing at the December release. If 10 can’t resolve, STOP and report the exact missing packages (that would be the only real Steve ask).

Clean up the two leftover test-gallery image versions.

Report: the fan-out rpm -qf verdicts (base/hana/sapapp), the 8/10 resolve results, and confirm the InSpec assertion fails correctly against an EPEL/pip az. Then hold for my MR go.
