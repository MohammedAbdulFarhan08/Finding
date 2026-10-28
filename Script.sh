Yes, squash the three inspec commits into one clean commit before the MR — the first two were superseded this session, no reason to ship that history. Keep the final c2eeb2f logic (ActiveState=='failed' + GPU-absence guard).

Confirmed the roles fix is validated from the #6 logs (FM at 535.309.01, enabled). When #7 lands, show me both builds green, service enabled, and systemd-no-failed-units passing with the exclusion now firing — then I'll raise the two linked MRs.
