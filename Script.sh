No new investigation needed — the 3-day-old draft stands. Just re-check the one thing that was blocking it: has SCSEC-8910 (John’s dual-arch pipeline) merged to main yet? 3 days ago it was only on branch c5406745-arm and the Ubuntu ARM build was held on it. John said this morning he’s nearly done and rushing Ubuntu, so check main + his branches and tell me whether the dual-arch pipeline is now landed.

If it’s merged → confirm target_architecture works off main, and get ready to build (hold the actual build for my go). Also live-verify the arm64 ISO path and that the arm64 packages resolve from our mirror (that was config-confirmed but never live-tested).
If it’s still on branch → stay held, and tell me what specifically is missing.

Two decisions I’ll make, flag them don’t investigate: (1) I’ll confirm the Graviton type — you proposed t4g.2xlarge, hold unless you see a reason to change. (2) The Pro-FIPS-amd64-only issue where ARM blocks enable_fips — surface exactly what that means for shipping: do ARM Ubuntu images go out non-FIPS, and is that a problem for the gov/NS-2 consumers? That’s the real open question, more than anything code-side.

Then raise the ARM subtasks and have the branch ready. Build held for my word.
