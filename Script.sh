Investigate only, change nothing, report back. Context: the nessus-agent role/pipeline pins Nessus Agent 10.9.0 for golden images; the amd64 deb at that version is in our S3 bucket (sap-core-images-binaries/packages/tenable/). For arm64, Tenable’s public download now only offers the latest agent (11.2.3) — 10.9.0 is behind a login we may not have. Before I decide whether to upload 11.2.3 for arm64 or chase the archived 10.9.0, tell me:

Exactly where and how 10.9.0 is pinned — file, variable name, is it a hardcoded version string, a “latest-in-bucket” lookup, or something else? Show the lines.
Does the amd64 build actually install 10.9.0 from the bucket today, or is the bucket just storing it? Trace how the role resolves the package it installs.
Can the version legitimately differ per architecture — i.e. does anything (the role, InSpec controls, a version assertion, scan logic) require arm64 and amd64 to run the same Nessus version? Would arm64 on 11.2.3 while amd64 stays 10.9.0 break or fail any check?
If I had to bump the pin to 11.2.3 for both arches instead, what’s the blast radius — what files change, and does it affect the amd64 images already building?
Report findings only. No edits, no commit.
