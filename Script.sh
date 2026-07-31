# EKS CloudWatch Observability — Context & Work Plan

**Purpose:** Grounding document for the VS Code / Copilot agent (and for teammates). It captures the problem, the goal, everything decided and discovered so far, the exact identifiers to use, and the constraints that must not be violated. Treat everything here as authoritative context. **Do not invent variable names, ARNs, resource names, or file paths that are not in this document — if something is marked `CONFIRM` or `TODO`, ask for it instead of guessing.**

_Last updated: 2026-07-31 · Owner: Afaaq Zarger (Platform/DevOps, OnePass)_

---

## 1. TL;DR — where things actually stand

- The `amazon-cloudwatch-observability` EKS add-on is **already installed and Active** on the dev cluster (**v6.4.0-eksbuild.1**), believed to be Terraform-managed (Jeff likely added the add-on block).
- **The gap:** the add-on shows **EKS Pod Identity = Not set** and **IRSA = Not set** in the console (dev, observed 2026-07-30). It has **no IAM identity**, so the CloudWatch agent + Fluent Bit pods are running but **silently failing to publish** logs/metrics (this is the classic "pods start fine, publish nothing" symptom).
- **The remaining work is IAM wiring, not add-on install:** create one IAM role, attach it to the add-on's service account via **EKS Pod Identity**, and make sure the resulting log groups are subscribed to Splunk. Then replicate to UAT and Prd.
- The CloudWatch → Splunk pipeline is **NOT ours to build** — Launchpad Centralized Logging owns it. But the add-on's log groups (`/aws/containerinsights/*`) are **not auto-subscribed**, so they need an explicit subscribe tag (see §7).

---

## 2. The problem

The EKS observability add-on is deployed but has no credentials. As a result:

- CloudWatch agent (metrics / Container Insights) and Fluent Bit (container logs) have no IAM permissions to call `logs:*` / CloudWatch APIs.
- No data reaches CloudWatch → therefore nothing reaches Splunk.
- This must be fixed and made consistent across **all three environments** (dev, UAT, prd), fully Terraform-managed to avoid the drift we already flagged from console-created resources.

## 3. The goal (definition of done)

EKS application/pod logs (plus Container Insights metrics and Application Signals) flow from `onepass-eks` into CloudWatch, and from CloudWatch into **Splunk via Launchpad Centralized Logging**, in **dev → UAT → prd**, with **all resources managed in Terraform** (no console-created drift). "Done" = logs verified **in the correct Splunk index**, not just visible in CloudWatch.

---

## 4. Environment & fixed identifiers (use these verbatim)

| Item | Value |
|---|---|
| Platform | Optum OnePass (UHG/Optum), AWS account migration to federated accounts |
| EKS cluster name | `onepass-eks` |
| Region | `us-east-2` (Ohio) |
| Dev account | `064977599863` (`onepass_federated_aws_dev`) |
| UAT account | `922181234939` |
| Prd account | `603613246298` |
| Add-on name | `amazon-cloudwatch-observability` |
| Add-on version (dev, installed) | `v6.4.0-eksbuild.1` (Active) |
| EKS Pod Identity Agent | `v1.3.10-eksbuild.3` (Active — Pod Identity infra is ready) |
| VPC CNI (context) | `v1.21.1-eksbuild.7` (Active) |
| Add-on namespace | `amazon-cloudwatch` |
| Add-on service account | `cloudwatch-agent` |
| Pod Identity trust principal | `pods.eks.amazonaws.com` |
| Required managed policies | `arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy` + `arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess` |
| Log groups created by add-on | `/aws/containerinsights/onepass-eks/{application,host,dataplane,performance}` |
| EKS module tfvars path (dev) | `platform-infra/platform/eks/vars/dev.tfvars` (UAT/prd equivalents alongside) |
| Terraform state | isolated per environment via `-backend-config` key at `init` |
| tfvars convention | `Vars/us-east-2/<env>.tfvars` pattern used elsewhere; the EKS module uses the `platform/eks/vars/<env>.tfvars` path above |

---

## 5. Hard constraints the agent MUST respect

- **Identity = EKS Pod Identity, NOT IRSA.** The add-on supports Pod Identity (add-on v3.1.0+), the Pod Identity Agent is already Active, and Pod Identity is the OnePass standard. Do not generate IRSA / OIDC trust policies.
- **Pod Identity trust is a service principal (`pods.eks.amazonaws.com`), not a federated OIDC principal.** The internal `tf-module-iam` module's lack of Federated-principal support therefore does **not** block this role.
- **No NAT Gateway.** All egress is via Aviatrix SNI firewall or VPC interface endpoints (PrivateLink). The agent/Fluent Bit reach CloudWatch via the `logs` (and CloudWatch metrics) interface endpoints — `CONFIRM` these endpoints exist in `us-east-2` before assuming reachability.
- **JFrog is the only registry** (`centraluhg.jfrog.io`); no public image egress. (The add-on pulls its images through the managed add-on mechanism — relevant only if we ever switch to the Helm chart.)
- **No console-created resources.** Everything Terraform. Console screenshot is for *observation only*.
- **Per-environment tfvars.** Hardcode values that don't vary across environments; parameterize only what does (account IDs, ARNs).
- **One service account → one IAM role** (Pod Identity is 1:1). Combine both managed policies onto the single `cloudwatch-agent` role; do not create two associations.

---

## 6. Decisions already made (with rationale)

- **Terraform from the start** — Afaaq flagged drift risk; **Carson** ("if it's going to TF anyway, start there") and **Jeff** both agreed. No console-first, no later import.
- **Jeff (platform/DevOps lead)** confirmed EKS add-ons are TF-supported and pointed to the format in `platform-infra/platform/eks/vars/dev.tfvars`. Format he gave:
  ```hcl
  amazon-cloudwatch-observability = {
    configuration_values = "{\"containerLogs\":{\"enabled\":true}}"
  }
  ```
  (He said "something like that maybe" — treat as the shape, not final wording.)
- **IAM scope:** `CloudWatchAgentServerPolicy` (covers all log/metric puts) **+** `AWSXrayWriteOnlyAccess`. The add-on enables **Container Insights AND Application Signals by default**; App Signals traces require the X-Ray write policy.
- **OTel Container Insights — evaluated and DEFERRED (ship classic):**
  - OTel logs write to the **same** `/aws/containerinsights/*` groups and need the **same** `CloudWatchAgentServerPolicy` → **no benefit** for the logs→Splunk path.
  - OTel log collection is currently **application-logs-only** (host/dataplane "future release").
  - OTel **metrics** are **public preview** (launched 2026-04-02); the preview region list (N. Virginia, Oregon, Sydney, Singapore, Ireland) **did not include us-east-2** — verify current GA/region status before betting on it.
  - The add-on can publish **both** OTel and classic metrics simultaneously, so shipping classic now does **not** lock us out. Revisit OTel metrics at GA in us-east-2.
  - `otelContainerInsights.enabled=true` is **required and off by default** if we ever enable it.

---

## 7. Reference docs

- **Internal (Jeff shared) — Launchpad Centralized Logging / CloudWatch:**
  `https://docs.hcp.uhg.com/public-cloud-account-management/cloudwatch`
  (Internal HCP page — the agent cannot fetch this; the relevant facts are captured in §8.)
- **AWS — CloudWatch Observability EKS add-on:**
  `https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/install-CloudWatch-Observability-EKS-addon.html`
- **AWS — Container Insights setup (EKS add-on):**
  `https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-EKS-addon.html`
- **AWS — OTel Container Insights logs (for the deferred OTel path):**
  `https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/container-insights-eks-otel-logs.html`

---

## 8. Key technical findings (load-bearing facts)

**Launchpad Centralized Logging (from the HCP doc):**
- Launchpad centralizes CloudWatch logs to Splunk — **we do not build any Firehose / HEC / delivery stream.** (An earlier assumption that we'd build the Firehose→Splunk hop is **ruled out** — do not reintroduce it.)
- Subscription is controlled by the **`1p-cl-subscribe` tag** on a log group: `True` = centralized, `False` = ignored.
- Log groups matching these prefixes are **auto-subscribed regardless of tag**: `/lp/cl/*`, `/aws/rds/*`, `/aws/lambda/*`, `/aws/states/*`, `/aws/ec2/*`, `/aws/apigateway/*`, `/aws/guardduty/*`, `API-Gateway-Execution-Logs`, `/aws/eks/*`.
- **`/aws/containerinsights/*` is NOT in that list.** → The add-on's log groups need an explicit **`1p-cl-subscribe: True`** tag to reach Splunk. **This is the #1 gotcha** — without it, logs land in CloudWatch and never reach Splunk, and you won't notice until you check Splunk.
- EKS **control plane** logs (`/aws/eks/*`) are auto-enabled by the `1p-cl-default-config-eks` lambda and auto-subscribed — **no action needed** for those.

**AWS add-on behavior (verified against AWS docs):**
- Installing the add-on installs the **CloudWatch agent** (metrics / Container Insights) and **Fluent Bit** (container logs), and enables **Container Insights + Application Signals by default**.
- Log groups: `/aws/containerinsights/onepass-eks/{application,host,dataplane,performance}`. Fluent Bit sends pod stdout/stderr to `.../application`.
- `CloudWatchAgentServerPolicy` includes `logs:CreateLogGroup/CreateLogStream/PutLogEvents/DescribeLogGroups/DescribeLogStreams`.
- **AL2023 nodes** (likely, given Karpenter): host + dataplane logs **do not vend by default**; **application logs do** — which is the set we care about for Splunk.
- CloudWatch **default retention is indefinite** → set a retention policy (Splunk is system of record; keep CW retention short, e.g. **7–14 days** as a buffer). `CONFIRM` retention value with team.
- v6.4.0 (installed) ≥ v6.2.0, so the add-on *supports* OTel metrics — not enabling it (see §6 OTel decision).

---

## 9. Work plan (what to build)

> Sequence as independent, buildable chunks. Do dev fully and **verify in Splunk** before touching UAT/prd.

**Chunk 1 — IAM role (per env)**
- One IAM role for the add-on's `cloudwatch-agent` SA.
- Trust: EKS Pod Identity (`pods.eks.amazonaws.com`).
- Attach: `CloudWatchAgentServerPolicy` + `AWSXrayWriteOnlyAccess`.

**Chunk 2 — Pod Identity Association (per env)**
- Associate SA `cloudwatch-agent` in namespace `amazon-cloudwatch` with the Chunk 1 role.
- Add this to the **existing PIA map** in the EKS module tfvars. `CONFIRM` the exact variable name/shape of that map (see §11) — **do not invent it.**
- PIA does not validate SA existence, so ordering vs. the add-on install does not matter.

**Chunk 3 — Add-on block (confirm, don't duplicate)**
- The add-on appears already added in TF. **Confirm it's committed** and where; do not create a second/duplicate block.
- Ensure `configuration_values` matches Jeff's format (`{"containerLogs":{"enabled":true}}`) and decide whether App Signals stays on (default) or is scoped out. `CONFIRM`.

**Chunk 4 — Log groups + Splunk subscribe tag (per env)**
- Pre-create `/aws/containerinsights/onepass-eks/application` (and `/host`, `/dataplane`, `/performance` as needed) in Terraform with:
  - tag `1p-cl-subscribe = "True"`, and
  - a retention policy (e.g. 7–14 days, `CONFIRM`).
- Fluent Bit's `auto_create_group` no-ops if the group already exists, so TF owns the tag + retention cleanly.
- **Pending confirmation from Carson** on whether Launchpad picks up `/aws/containerinsights/*` on its own or genuinely needs this tag (docs say tag). If Carson says an internal lambda handles it, this chunk may reduce to retention-only.

**Chunk 5 — Validate in dev**
- Agent pods have creds (no CrashLoopBackOff, no permission errors in `cloudwatch-agent` pod logs).
- `aws logs describe-log-groups --log-group-name-prefix "/aws/containerinsights/onepass-eks"` shows non-zero `StoredBytes`.
- Subscribe tag present on the groups.
- **Logs visible in the correct Splunk index** (`CONFIRM` index name with Carson).

**Chunk 6 — Roll to UAT, then Prd**
- Replicate Chunks 1–4 in `922181234939` (UAT) and `603613246298` (prd) tfvars. Prd release follows Change Request → manual sync convention.

---

## 10. Terraform reference shapes (illustrative — match existing module conventions)

> These are **shapes to guide structure**, not copy-paste truth. The real module already has patterns for IAM roles, Pod Identity associations, and the add-on map — **prefer the existing module's variables and modules over these sketches.** Where a name is `TODO`/`CONFIRM`, get the real one before writing.

```hcl
# Chunk 1 — IAM role (Pod Identity trust)
data "aws_iam_policy_document" "cw_agent_trust" {
  statement {
    actions = ["sts:AssumeRole", "sts:TagSession"]
    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cw_agent" {
  name               = "onepass-eks-cloudwatch-agent-role"  # CONFIRM naming convention
  assume_role_policy = data.aws_iam_policy_document.cw_agent_trust.json
}

resource "aws_iam_role_policy_attachment" "cw_agent_server" {
  role       = aws_iam_role.cw_agent.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "cw_agent_xray" {
  role       = aws_iam_role.cw_agent.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}

# Chunk 2 — Pod Identity Association
# PREFER adding to the existing PIA map variable in dev.tfvars instead of a raw resource.
resource "aws_eks_pod_identity_association" "cw_agent" {
  cluster_name    = "onepass-eks"
  namespace       = "amazon-cloudwatch"
  service_account = "cloudwatch-agent"
  role_arn        = aws_iam_role.cw_agent.arn
}

# Chunk 4 — Log group with Splunk subscribe tag + retention
resource "aws_cloudwatch_log_group" "ci_application" {
  name              = "/aws/containerinsights/onepass-eks/application"
  retention_in_days = 14        # CONFIRM
  tags = {
    "1p-cl-subscribe" = "True"  # required so Launchpad centralizes to Splunk
  }
}
# repeat for /host, /dataplane, /performance as needed
```

---

## 11. Pending items / open questions / blockers

**Need from Carson (app dev / Launchpad SME):**
- Does Launchpad centralize `/aws/containerinsights/*` automatically, or is the `1p-cl-subscribe: True` tag required? (Docs indicate the tag.)
- Which **Splunk index** should these logs land in (for verification)?

**Need from Afaaq / the repo (feed to the agent before it writes final TF):**
- The **exact PIA map variable name and shape** in `platform-infra/platform/eks/vars/dev.tfvars`.
- The current **add-on / addons map** block (to confirm the add-on entry and avoid duplication).
- The module's **IAM role naming convention** and any shared helper module for roles.

**Decisions to lock:**
- Retention value for the containerinsights log groups (proposed 7–14 days).
- App Signals: keep on (default) or scope out.
- `CONFIRM` the `logs` / CloudWatch metrics **VPC interface endpoints** exist in `us-east-2` (no NAT).

**Deferred (explicitly not blocking this rollout):**
- OTel Container Insights metrics — revisit at GA in `us-east-2`.

---

## 12. Guardrails for the agent (anti-hallucination)

1. Use only the identifiers in §4. Do not fabricate cluster names, account IDs, ARNs, namespaces, or SA names.
2. Generate **Pod Identity** trust (`pods.eks.amazonaws.com`), never IRSA/OIDC.
3. Do not add Firehose, Kinesis, HEC, or any CW→Splunk delivery resources — Launchpad owns that hop.
4. Do not create a duplicate add-on block; the add-on already exists in TF (confirm first).
5. For the PIA map and IAM naming, **use the real module structure** (§11). If it's not provided, emit a clear `// TODO: confirm existing variable name` marker instead of inventing one.
6. Keep every resource per-environment and Terraform-managed; never suggest console steps as the solution.
7. When unsure, surface the question — do not guess.
