Next: author the SLES 16 FIPS task files, per the settled direction in the project memory.

Create fips/tasks/sles/16/sp0/{check,enable,disable}-fips.yml. Do NOT touch the
path formula in fips/tasks/main.yml.

- check-fips.yml: same sysctl crypto.fips_enabled check as SP6.
- enable-fips.yml: model on SP6 (libopenssl-3-fips-provider, update-crypto-policies
  --set FIPS, fips=1 via both GRUB keys, grub2-mkconfig, dracut --add fips).
  Keep the structure close to SP6 so reviewers can diff the two easily. Use
  patterns-base-fips as the 16 pattern name and keep failed_when: false where SP6
  has it. Add a short comment on each task I haven't verified on a live 16 build
  (openssl.cnf provider wiring, EFI grub path, update-bootloader).
- disable-fips.yml: use fips-mode-setup --disable, since it exists on 16.

Constraints: keep SLES 15 behaviour unchanged, add nothing security-weakening, and
don't push. Show me the full diff, plus a short list of every assumption that's
inferred from SLES 15 / Leap 16 rather than documented for SLES 16, and wait for my
OK before committing.
