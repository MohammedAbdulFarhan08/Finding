One root cause, two symptoms. Everything traces to pods that can't pull from JFrog — ImagePullBackOff across cert-manager, pass, strimzi, schema-registry (unrelated namespaces = shared pull path, not app bugs). No pods Running → target groups empty → ALB has no healthy backend → workstation requests hang. What the devs are calling a "DNS issue" is almost certainly that hang, i.e. a symptom of the empty target groups, not a separate Route53/external-dns problem.

But there's one way DNS is the actual root, not a symptom — and it's worth ruling out first because it unifies everything: if CoreDNS is broken, pods can't resolve centraluhg.jfrog.io, which surfaces exactly as ImagePullBackOff everywhere and breaks in-cluster resolution the devs might be hitting. So check CoreDNS before chasing external DNS:

bash
kubectl -n kube-system get pods -l k8s-app=kube-dns

If CoreDNS is healthy, DNS is a red herring on the outage — it's the pull path, and you branch on a pod's events:

401/403 → rotated JFrog imagePullSecret not re-synced (Blessing owns rotation — my lead given the timeline below)
connection reset / TLS handshake / timeout → Aviatrix SNI allowlist or JFrog egress from the new nodes

Timeline anchor for the agent — don't skip this: node ages show a rotation ~20h ago (nodes are 21h/20h/19h; note ip-6-152-2-28 is on a different AMI bca9cf6 vs 93b80c6). The 20–21h ImagePullBackOff band (cert-manager, schema-registry, strimzi) started exactly then and never pulled; the ~90m band (billing/community/offerings) is CI redeploys hitting the same wall. So the question to drive the agent is: what changed ~20h ago — node roll, JFrog cred rotation, or a VPC-endpoint/Aviatrix change on the new node template.

Before touching Route53, one workstation nslookup select.dev.one-pass-dev.com settles the DNS framing: resolves to the ALB → external DNS is fine, it's the backend; NXDOMAIN → then external-dns is a real second issue.

Two things to explicitly de-scope so the agent doesn't rabbit-hole: ebs-csi-controller crashloop (pre-existing, EBS not pull-related) and pass-offerings crashloop (it pulled, so app-level — DB/secrets, deal with after the pull path is restored).
