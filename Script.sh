Approved — go with the revised Change A: replace the empty security= with 
"security=selinux selinux=1" (explicit LSM, not blank — safer with FIPS on the line and 
self-documenting). Confirmed the regex assumes security= is the last token, which your real 
line shows it is; just make sure nothing in a later task appends after security= before this 
runs.

Change B: agreed, it's moot — no base dup to fix. Don't do it. If you want, re-check the 
post-FIPS rendered line once on the validation build just to confirm fips=1 appears once, but 
no code change.

Apply revised Change A, then proceed with the rest (packages, config, relabel, first-boot 
flip, InSpec) and run the enforcing validation build. Hold to the hard gate: getenforce= 
Enforcing, relabel done, zero AVCs against sshd/chronyd/clamav/nessus/cwa/ssm, and SSH 
actually connects with sshd reading 10-scs-hardening.conf. No SSH proof = not a pass.
