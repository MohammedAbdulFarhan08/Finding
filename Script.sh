# cert-manager — Build Context (OnePass Platform)

> **Purpose of this file:** full context for implementing cert-manager in the OnePass EKS cluster via ArgoCD GitOps.
>
> **Rules for the agent reading this:**
> 1. Do **not** invent values for anything marked `<<FILL: ...>>`. Stop and ask.
> 2. Do **not** pull images or charts from public registries (quay.io, charts.jetstack.io). The cluster has **no NAT gateway** and an **Aviatrix SNI firewall** blocks egress. Everything comes from JFrog.
> 3. Do **not** modify anything under the application teams' ownership (see §9). This work stops at producing the Secret.
> 4. Match the Helm chart version to the image tags exactly.

---

## 1. Goal

`pass-admin` currently calls `pass-offerings` over plaintext HTTP inside the cluster:

```
http://pass-offerings.pass.svc.cluster.local
```

We need this call encrypted. Decision (confirmed with Jeffrey McGuffee, platform lead): **install cert-manager with a self-signed internal CA**. Not ACM PCA, not a service mesh.

The existing `*.dev.one-pass-dev.com` private cert is a **leaf certificate**, not a CA — it cannot issue, and it does not cover `.svc.cluster.local` names. It is irrelevant to this work.

Public certs (PCAM / Cloudflare / ACME) are a **separate trust domain** and are also irrelevant here. No public CA will issue for internal cluster names.

---

## 2. Environment facts

| Item | Value |
|---|---|
| Cluster | `onepass-eks`, `us-east-2` |
| Dev account | `064977599863` |
| UAT account | `922181234939` |
| Prd account | `603613246298` |
| GitOps repo | `github.com/optum-one-pass/platform-apps` (single `main` branch) |
| CD tool | ArgoCD, App-of-Apps; root app watches `platform/` recursively |
| Env separation | folders — `dev/`, `uat/`, `prd/` |
| Registry | JFrog Artifactory, `centraluhg.jfrog.io` |
| App namespace | `pass` |
| Target scope | **dev only** for now |

### Established cluster conventions (follow these)

- CRDs are applied **manually via kubectl**, not by Helm. Helm values set CRD installation to `false`. This is how ASCP was done.
- Secrets are mounted at `/mnt/secrets/` by convention (CSI Secrets Store Driver + ASCP 2.0.0 + EKS Pod Identity). **cert-manager does not use this** — it writes native Kubernetes Secrets. Don't conflate the two.
- Terraform uses per-region/env var-files.
- Dev ArgoCD Applications use `selfHeal: false` (developers make manual cluster changes in dev). UAT/Prd use `selfHeal: true`.

---

## 3. Artifacts already obtained

Both the Helm chart and the container images have been pulled from JFrog.

```
<<FILL: chart version, e.g. v1.16.2>>
<<FILL: JFrog Helm repo URL or vendored chart path in platform-apps>>
<<FILL: JFrog docker repo path for cert-manager images, e.g. centraluhg.jfrog.io/glb-docker-uhg-loc>>
<<FILL: image tag, must match chart version>>
```

cert-manager ships **four** images. Confirm all four are present before proceeding:

- `cert-manager-controller`
- `cert-manager-webhook`
- `cert-manager-cainjector`
- `cert-manager-startupapicheck` — optional; if unavailable set `startupapicheck.enabled: false`

An `imagePullSecret` may be required in the `cert-manager` namespace for `centraluhg.jfrog.io`.
`<<FILL: existing pull secret name, or confirm cluster-wide mechanism exists>>`

---

## 4. Target file layout in `platform-apps`

```
platform/
  cert-manager/
    argocd-app.yaml            # ArgoCD Application for the Helm release
    values.yaml                # Helm values with JFrog overrides
    crds/
      cert-manager.crds.yaml   # vendored from GitHub release, applied by kubectl
  cert-manager-config/
    argocd-app.yaml            # ArgoCD Application for issuers + certs
    00-selfsigned-issuer.yaml
    01-ca-certificate.yaml
    02-ca-issuer.yaml
    03-pass-offerings-cert.yaml
  trust-manager/
    argocd-app.yaml
    values.yaml
    bundle.yaml
```

Keeping the cert-manager **install** separate from the **config** (issuers/certificates) is deliberate. The webhook must be running and healthy before any `Issuer`/`Certificate` resource can be admitted by the API server. Two Applications with sync waves is the reliable way to enforce that.

---

## 5. Ordering constraints (important — this is where installs fail)

Apply in this order:

1. **CRDs** (kubectl, or ArgoCD sync-wave `-2`)
2. **cert-manager Helm release** — wait for controller + webhook pods `Ready`
3. **SelfSigned ClusterIssuer** (wave `1`)
4. **CA Certificate** with `isCA: true` (wave `2`)
5. **CA ClusterIssuer** referencing the CA secret (wave `3`)
6. **Certificate for pass-offerings** (wave `4`)
7. **trust-manager + Bundle** (after cert-manager is healthy)

Use ArgoCD sync waves via the annotation:

```yaml
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "1"
```

### Known ArgoCD + cert-manager issue

cert-manager CRDs are large and exceed the 262144-byte limit on the `kubectl.kubernetes.io/last-applied-configuration` annotation. If CRDs are synced through ArgoCD, the Application **must** use server-side apply:

```yaml
syncPolicy:
  syncOptions:
    - ServerSideApply=true
```

If applying CRDs by hand, use `kubectl apply --server-side` for the same reason.

---

## 6. Helm values (`platform/cert-manager/values.yaml`)

```yaml
# CRDs are applied separately — same pattern as ASCP.
# NOTE: key name depends on chart version.
#   chart >= v1.15 : crds.enabled
#   chart <  v1.15 : installCRDs
crds:
  enabled: false

global:
  leaderElection:
    namespace: cert-manager

image:
  repository: <<FILL: jfrog path>>/cert-manager-controller
  tag: <<FILL: version>>

webhook:
  image:
    repository: <<FILL: jfrog path>>/cert-manager-webhook
    tag: <<FILL: version>>

cainjector:
  image:
    repository: <<FILL: jfrog path>>/cert-manager-cainjector
    tag: <<FILL: version>>

startupapicheck:
  enabled: true   # set false if the image is not available in JFrog
  image:
    repository: <<FILL: jfrog path>>/cert-manager-startupapicheck
    tag: <<FILL: version>>

# imagePullSecrets:
#   - name: <<FILL>>

resources:
  requests:
    cpu: 10m
    memory: 64Mi
```

> Verify each key against the values.schema.json of the exact chart version pulled. Key names have moved between versions — do not assume.

---

## 7. Issuer chain

Three objects, each because the previous one cannot do the job alone.

### 7.1 SelfSigned ClusterIssuer — bootstrap only

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned-bootstrap
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  selfSigned: {}
```

Signs exactly one thing — the CA below. Never used again.

### 7.2 CA Certificate — the trust root

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: onepass-internal-ca
  namespace: cert-manager
  annotations:
    argocd.argoproj.io/sync-wave: "2"
spec:
  isCA: true
  commonName: onepass-internal-ca
  secretName: onepass-internal-ca-secret
  duration: <<FILL: decide — see note below>>
  renewBefore: <<FILL>>
  privateKey:
    algorithm: ECDSA
    size: 256
  issuerRef:
    name: selfsigned-bootstrap
    kind: ClusterIssuer
    group: cert-manager.io
```

> **Decision needed:** CA lifetime. This is a trust root the platform now owns. Rotating it later requires coordinating every service that trusts it. Do not accept the default (90 days) without thinking — a CA typically wants years, and leaf certs want short lifetimes. Common choice: CA 5 years, leaf 90 days.

### 7.3 CA ClusterIssuer — signs everything else

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: onepass-ca-issuer
  annotations:
    argocd.argoproj.io/sync-wave: "3"
spec:
  ca:
    secretName: onepass-internal-ca-secret
```

The referenced secret must live in the namespace cert-manager runs in (`cert-manager`), because `ClusterIssuer` resolves secrets from the controller's own namespace — **not** from the consuming namespace.

---

## 8. Certificate for pass-offerings

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: pass-offerings-tls
  namespace: pass
  annotations:
    argocd.argoproj.io/sync-wave: "4"
spec:
  secretName: pass-offerings-tls
  duration: 2160h    # 90d
  renewBefore: 720h  # 30d
  privateKey:
    algorithm: RSA
    size: 2048
    rotationPolicy: Always
  dnsNames:
    - pass-offerings
    - pass-offerings.pass
    - pass-offerings.pass.svc
    - pass-offerings.pass.svc.cluster.local
  issuerRef:
    name: onepass-ca-issuer
    kind: ClusterIssuer
    group: cert-manager.io
```

**All four SAN forms are required.** Kubernetes DNS resolves any of them, and TLS verification fails if the client's hostname is not on the cert. The client currently uses the FQDN, but short forms cost nothing and prevent a re-issue later.

Resulting Secret (`kubernetes.io/tls`) contains `tls.crt`, `tls.key`, `ca.crt`.

### If pass-offerings is a JVM app

Have cert-manager emit a keystore directly rather than making the app team convert PEM:

```yaml
spec:
  keystores:
    pkcs12:
      create: true
      passwordSecretRef:
        name: pass-offerings-keystore-password
        key: password
```

`<<FILL: confirm stack with Anuroop — Spring Boot or not>>`
The password Secret must be created separately. Do not hardcode a password in git.

---

## 9. Scope boundary — NOT this work

The following are **application team changes** (Anuroop Buggaveeti). Do not implement, do not modify their charts.

**pass-offerings (server):**
- Mount `pass-offerings-tls` Secret as a volume
- Configure the app server to serve TLS on `8443`
- Add `containerPort: 8443` and the Service port mapping
- Change readiness/liveness probes to `scheme: HTTPS` — otherwise the pod crashloops

**pass-admin (client):**
- Mount the CA bundle and load it into the truststore
- Change the URL from `http://pass-offerings.pass.svc.cluster.local` to `https://pass-offerings.pass.svc.cluster.local:8443`

cert-manager produces a Secret. It does **not** make anything speak HTTPS. A cert on disk is inert until the application loads it.

---

## 10. trust-manager (CA bundle distribution)

Without this, the CA cert must be hand-copied into every consuming namespace. Install alongside cert-manager.

```yaml
apiVersion: trust.cert-manager.io/v1alpha1
kind: Bundle
metadata:
  name: onepass-internal-ca-bundle
spec:
  sources:
    - secret:
        name: onepass-internal-ca-secret
        key: ca.crt
  target:
    configMap:
      key: ca-bundle.crt
      namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: pass
```

Notes:
- trust-manager reads sources only from its configured trust namespace (default `cert-manager`).
- `secret` as a source type requires a recent trust-manager version and may need `--secret-targets-enabled` / equivalent flag. `<<FILL: confirm version available in JFrog>>`
- The API group version may differ by release — verify against the chart pulled.

---

## 11. Renewal behaviour — must be handled

cert-manager renews automatically and rewrites the Secret. **Running pods do not pick this up.** Most servers read the keystore once at startup and hold it in memory. A renewed cert changes nothing until the pod restarts.

Options, pick one and document it:
1. Deploy **Reloader** and annotate the Deployment to restart on Secret change
2. Accept scheduled restarts aligned to cert lifetime
3. Application-level file watching (app team work)

This is the failure mode that appears silently ~60 days after a successful install.

---

## 12. Verification

```bash
# CRDs present
kubectl get crd | grep cert-manager

# controller, webhook, cainjector all Running
kubectl get pods -n cert-manager

# issuers must show READY=True
kubectl get clusterissuer

# certificate issued
kubectl get certificate -n pass
kubectl describe certificate pass-offerings-tls -n pass

# inspect the SANs actually issued
kubectl get secret pass-offerings-tls -n pass \
  -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -noout -text | grep -A1 "Subject Alternative Name"

# CA bundle landed in the app namespace
kubectl get configmap -n pass onepass-internal-ca-bundle

# end-to-end, once the app team has enabled TLS
kubectl run -n pass tls-test --rm -it --image=<<FILL: golden curl image from JFrog>> -- \
  curl -v --cacert /path/to/ca.crt https://pass-offerings.pass.svc.cluster.local:8443/health
```

---

## 13. Open items

- [ ] Confirm all four images present in JFrog + exact tag
- [ ] Confirm chart version and whether it's a JFrog Helm remote or vendored
- [ ] Confirm `crds.enabled` vs `installCRDs` for that chart version
- [ ] Decide CA duration and rotation approach
- [ ] Confirm pass-offerings stack (JVM → keystore format)
- [ ] Decide pod-restart-on-renewal strategy
- [ ] Confirm imagePullSecret requirement for the cert-manager namespace
- [ ] Confirm trust-manager version supports a `secret` source
- [ ] Dev only for now — UAT/Prd rollout is a later phase

---

## 14. Constraints recap

- No public registry egress. JFrog only.
- No NAT gateway; Aviatrix SNI firewall blocks by hostname. Symptom of a block: `Connection reset by peer` immediately after TLS Client Hello.
- ArgoCD dev apps use `selfHeal: false`.
- Config changes merge to `platform-apps` **before** dependent application changes, to avoid runtime failures.
- Pin versions explicitly. Never `latest`.
