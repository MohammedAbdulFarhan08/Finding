Before we delete the boot-test RG, I need a proper evidence pack for STOI-14841 showing the azure-cli fix works. Do not tear down c5425849-bt-8-10 until the live evidence from the 8.10 and 10.2 VMs is captured and saved.

What I need: one clean artifact (a markdown file I can attach to the ticket and reference from the MR) with real command output for each validated image: 9.6 base/hana/sapapp, 8.10, and 10.2. It should show:

that az is the Microsoft rpm from the Microsoft repo (not EPEL, not pip), with its version
that the old pip install is gone
that FIPS is on
that az works for real under FIPS
the build job and image version each result came from

Also include the InSpec guard’s negative and positive test results, and the evidence that the dependency closure resolved from our CDN2 mirror with no outside reach.

For the 8.10 and 10.2 VMs, capture fresh live output now. For 9.6, where the VMs are already gone, reconstruct from the logged outputs in this session and the build logs, and label clearly that those were captured at the time rather than re-run. Don’t fabricate or paraphrase any output, and say plainly if something can’t be recovered.

Redact tenant IDs, subscription IDs, tokens, and anything else sensitive before it goes in the file, since this will be attached to a Jira ticket.

When it’s saved, show me the file and tell me which items are live-captured vs. recovered. Then tear down the RG. Still no MR until I approve.
