Context update: the call with Steve already happened. Decisions from it —
(1) STIG/DISA is entirely Ram's now, he's refactoring all DISA roles in a new
format, so I'm not touching STIG. (2) Steve said go ahead and build the FIPS side
solo using vendor docs, loop him in only if stuck — there's no separate FIPS
planning call coming. (3) On the sp0 path naming, Steve said just create the
sles/16/sp0 directory with check/enable/disable, so that's decided — don't frame it
as an open design question.

Also fold in your own two findings from this research, since they close things I'd
raised on the call: 16 ships GRUB 2.12 (not systemd-boot), so the grub2-mkconfig
tasks carry over and the bootloader rewrite I worried about isn't needed; and 16
ships fips-mode-setup, so the enable task may be simpler than SP6's hand-rolled
sequence.

So drop the "for the Steve/Ram call" framing. The real open items are only the
build-verifiable ones: does patterns-base-fips resolve on the 16 CDN2 mirror (Steve's
side, Updates/16.0 not on CDN2 yet), and how the openssl-3 provider gets wired into
openssl.cnf. Yes, save the FIPS findings to the project memory file, but write them
as settled direction + those two verify-on-build unknowns, not as questions for a
call.
