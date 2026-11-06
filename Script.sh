Before I give the MR go, two coverage checks:

Are base / hana / sap the ONLY presets any azure RHEL image builds with? Specifically — do any azure RHEL variants build with the Nvidia, Gardener-Shoot, or cHost presets? If yes, they still lack MS-prod and would still ship EPEL’s azure-cli — same miss-a-variant pattern that let 6203 recur. If so, apply the same MS-prod+exclude+gpgkey treatment there. If base/hana/sap is the complete set, confirm that and we’re done.
8.10 and 10.2 were dep-resolve dry-runs, not boot-tests — resolve proves install, not that az runs under FIPS. If the December release ships azure 8.10 or 10.2 images, do one boot-test per major (FIPS on, az real command + rpm -qf) so runtime is proven on all three majors, not just 9.6. If those majors aren’t in the December azure scope, tell me and we defer them.

Once those two are answered, go ahead and tidy the sap changelog line and I’ll give the MR go.
