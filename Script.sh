Context: STOI-14396. Cleared to proceed (reporter directed it, John + Steve signed off on 
blast radius). I'm bumping the Gardener-Nvidia driver from 535 to 580.178.04 on the EXISTING 
roles branch stoi-14396-nvidia-fabric-manager (current head 44203f3) in ~/c5425849-nvidia. 
This is an amendment to the existing FM fix, NOT a new branch.

The change is ONLY the pinned NVIDIA triplet in the shared nvidia preset (the single 
products/nvidia.yml install path). Everything else stays exactly as-is.

Do it in this order, and STOP for my approval before launching any build:

1. LOCATE: find the file where the 535 triplet is currently pinned — grep for 
   nvidia-driver-535-server / nvidia-fabricmanager-535 / libnvidia-nscq-535. Confirm the 
   exact path and show me the current pinned lines for both OSes (jammy 22.04 + noble 24.04). 
   Current pins are 535.309.01-0ubuntu0.22.04.2 / -0ubuntu0.24.04.2.

2. VERIFY THE TARGET ON THE MIRROR FIRST (don't hardcode from my message): from the CDN2 
   mirror the build pulls from, confirm the exact available build string for 580.178.04 for 
   ALL THREE -580 packages on BOTH OSes — nvidia-driver-580-server, nvidia-fabricmanager-580, 
   libnvidia-nscq-580. I believe it's 580.178.04-0ubuntu0.22.04.1 (jammy) / -0ubuntu0.24.04.1 
   (noble) — note the suffix is .1, not the .2 the 535 pin used — but VERIFY it rather than 
   trust me, and confirm all three resolve at the identical string per OS (they must stay in 
   lockstep). If any of the three isn't at 580.178.04, STOP and tell me — do not guess a 
   nearest version.

3. EDIT: change the three package names 535 -> 580 and the version pins to exactly what you 
   verified in step 2, for both OSes. Change NOTHING else in the file.

4. DO NOT TOUCH: the FM systemd-enable task (the service unit nvidia-fabricmanager.service is 
   version-independent, so it needs no change); the inspec branch/exclusion 
   (stoi-14396-nvidia-fm-scan-exclusion — it keys on ActiveState=failed + /dev/nvidia0 absence, 
   version-independent, leave it completely alone); and the test_c5425849_build.yml pointer 
   (leave it pointing at the fix branches so the validation build picks them up — I'll strip 
   it before the MR).

5. SHOW ME: the full diff plus the verified per-OS versions from step 2. Then STOP and wait 
   for my explicit go-ahead before doing anything else.

6. ON MY APPROVAL ONLY: commit to the roles branch with a clear message (e.g. "STOI-14396: 
   bump NVIDIA driver 535.309.01 -> 580.178.04 (lifecycle, R580 LTSB)"), then kick a 
   validation build on BOTH 22.04 and 24.04.

7. REPORT against this checklist, both OSes: build succeeded; all three -580 packages 
   installed at 580.178.04; nvidia-fabricmanager enabled at boot; systemd-no-failed-units 
   passing (the exclusion still firing correctly); inspec profile summary at 0 failures. 
   Flag any deviation plainly — don't smooth it over.
