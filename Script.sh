Keep the raw evidence blocks separate from the reporter-facing comment, don't fold all six into it.

Give me two things:
1. A short reporter-facing ticket comment for STOI-12284, tagging David McGregor: leads with the two asks (swapon --summary + free -h from the failing box, and confirmation it was the unmodified AMI with no custom launch settings), then a brief "here's why we're asking" — we reproduced your exact setup on a 2GB box and it patched clean, and the image ships 3.8GB active swap. Inline at most the swapon output and the clean-completion line. Keep it tight and non-accusatory.
2. The full six-block evidence as a separate "Full test evidence" block I can hand John or drop lower in the ticket.

Apply your own caveats: drop any "new kernel installed" claim (you didn't capture it — APT_EXIT=0 is the real claim), and mark the instance IDs as terminated. Don't change anything in a repo.
