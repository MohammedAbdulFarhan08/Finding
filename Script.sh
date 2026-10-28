Agreed — /dev/nvidia0 only is the right per-GPU discriminator, and good call flagging that you can't verify its absence on the ephemeral builder. Let #8 run.

One thing: to avoid another reason-in-the-dark round, add the device-node debug dump NOW rather than waiting for #8 to maybe fail — have the control log what's actually in /dev/nvidia* at scan time, so #8's output shows us the real device state either way. If #8 is green, great, we have proof for the record; if it's not, we already have the evidence instead of needing a #9 to gather it.

Roles stays validated from #6. When #8 lands, show me both builds green, the device-node dump, service enabled, and systemd-no-failed-units passing — then the two linked MRs.
