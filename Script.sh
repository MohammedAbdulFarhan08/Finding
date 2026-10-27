Yes, draft the STOI-12284 update for John. Lead with the headline that we could not reproduce the OOM — a properly-swapped 2GB box patches the reporter's exact package set in ~7 min with >1GB free, and both our hypotheses (no swap in image / concurrent-apt race) are refuted by live evidence, with the swap figures and the dpkg-lock mechanism as proof.

Then the conclusion: the image ships and boots with 3.8GB active swap, so there's no fix to make on our side — the only thing consistent with the reporter's failure is that their specific instance had no active swap. 

Then the two asks for the requester: swapon --summary / free -h from the failing box (or its serial console), and confirmation it was the unmodified AMI with no custom launch (root-volume resize, user-data, re-bundled/older image, non-default block device mapping — anything that could drop the baked /swap.img).

Keep it factual and ready for John to read or paste to the requester. Mention the unattended-upgrades mask not persisting as a one-line side note only — flag it's not the cause and worth a separate minor-hygiene ticket. Don't frame the whole thing around it.
