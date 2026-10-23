The chrony Gov verification image EXISTS — confirmed in the portal. Gov gallery
scs_golden_images_test, definition C5425849-Golden-CDN2-SCS-RHEL-9.6-HANA, version
2026.1022.2230, published 10/22 5:42 PM, USGov Virginia, in the Core SMS Gov
subscription (4db6be59-950f-4ea8-88db-17fd59f20348). My CLI is logged into Azure Gov.

I want to deploy a throwaway test VM from this image and verify the chrony fix. But
read this carefully on HOW to work:

STRICT RULES:
- NO deletions of anything, at all, this session. Not resource groups, not VMs, not
  disks, nothing. If cleanup is needed later I'll do it myself after I've confirmed.
- Take every step one at a time. Show me the exact command BEFORE running it, tell me
  what it does and what you expect, and wait for my go-ahead. No chained multi-step
  runs.
- Don't touch the gallery, the image, or anything in share_image_gallery_core — the
  image is read-only input, we only deploy FROM it.
- Give me each command as you go so I can note them down.

What I want to end up doing (step by step, with my approval at each step):
1. Confirm my current az context (account show) and that I can see the image.
2. Create a NEW throwaway resource group just for this test (stoi14182-verify-rg) in
   usgovvirginia — confirm the command first.
3. Deploy ONE VM from the image into that RG: Standard_D4s_v3, Standard security type
   (not Trusted launch), generated SSH key, username azureuser. Public IP only if Gov
   policy allows — flag it if it errors.
4. SSH in and run the verification checks: chrony-azure-phc.service active, its
   journal, grep refclock/makestep/sourcedir in /etc/chrony.conf, and chronyc sources
   -v (the key one — must be populated with the PHC refclock on this air-gapped box).

Start with step 1 only. Show me the command, don't run anything else.
