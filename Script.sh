# ---------------------------------------------------------------------------
# pass-edge IAM role  (Amazon Location Service — Places)
#
# Grants pass-edge geocoding access to Amazon Location Service via EKS Pod
# Identity. Scope is intentionally minimal: geo-places:Geocode and
# geo-places:ReverseGeocode on the AWS-managed default Places provider in
# us-east-2. No Maps, no Routes (confirmed with Jeff).
#
# DEFERRED — do NOT switch the pass-edge deployment to pass-edge-sa until both
# of these are in place, or pass-edge loses its current Secrets Manager access:
#   1. Secrets Manager scope. A service account maps to exactly ONE IAM role
#      under Pod Identity, so this role must also carry the secrets access
#      pass-edge has today (via pass-secrets-sa). Add the secretsmanager +
#      kms:Decrypt statements to the permissions policy below once the secret
#      ARNs are confirmed.
#   2. Pod Identity Association. Commented stub at the bottom — fill in the
#      cluster name and the confirmed namespace, then uncomment.
# ---------------------------------------------------------------------------

# --- Trust policy: EKS Pod Identity ---------------------------------------
data "aws_iam_policy_document" "pass_edge_trust" {
  statement {
    sid     = "EksPodIdentity"
    effect  = "Allow"
    actions = ["sts:AssumeRole", "sts:TagSession"]

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

# --- Permissions policy: Location Service (Places) ------------------------
data "aws_iam_policy_document" "pass_edge_permissions" {
  statement {
    sid    = "LocationPlacesGeocode"
    effect = "Allow"
    actions = [
      "geo-places:Geocode",
      "geo-places:ReverseGeocode",
    ]
    # AWS-managed default provider — account-agnostic, identical across
    # dev/uat/prd (note the empty account-id segment).
    resources = ["arn:aws:geo-places:us-east-2::provider/default"]
  }

  # DEFERRED — secrets access folds in here (one SA = one role):
  # statement {
  #   sid     = "SecretsManagerRead"
  #   effect  = "Allow"
  #   actions = ["secretsmanager:GetSecretValue"]
  #   resources = [
  #     # "arn:aws:secretsmanager:us-east-2:<account>:secret:onepass-eks/pass-edge-*",
  #   ]
  # }
  # statement {
  #   sid     = "KmsDecryptForSecrets"
  #   effect  = "Allow"
  #   actions = ["kms:Decrypt"]
  #   resources = [
  #     # "arn:aws:kms:us-east-2:<account>:key/<secrets-cmk-id>",
  #   ]
  # }
}

# --- Role + policy --------------------------------------------------------
resource "aws_iam_role" "pass_edge" {
  name               = "pass-edge-role"
  assume_role_policy = data.aws_iam_policy_document.pass_edge_trust.json

  tags = {
    Service   = "pass-edge"
    ManagedBy = "terraform"
  }
}

resource "aws_iam_policy" "pass_edge_permissions" {
  name   = "pass-edge-permissions"
  policy = data.aws_iam_policy_document.pass_edge_permissions.json
}

resource "aws_iam_role_policy_attachment" "pass_edge_permissions" {
  role       = aws_iam_role.pass_edge.name
  policy_arn = aws_iam_policy.pass_edge_permissions.arn
}

# --- Pod Identity Association (DEFERRED — needs confirmed namespace) -------
# resource "aws_eks_pod_identity_association" "pass_edge" {
#   cluster_name    = "<eks-cluster-name>"
#   namespace       = "pass"            # confirm with Jeff before enabling
#   service_account = "pass-edge-sa"
#   role_arn        = aws_iam_role.pass_edge.arn
# }

output "pass_edge_role_arn" {
  value = aws_iam_role.pass_edge.arn
}
