locals {
  eks_cluster_oidc_issuer = replace(var.eks_cluster_oidc_issuer_url, "https://", "")
}

module "service_account_label" {
  source  = "cloudposse/label/null"
  version = "0.22.0"

  # To remain consistent with our other modules, the service account name goes after
  # user-supplied attributes, not before.
  attributes = compact(concat(module.this.attributes, var.service_account_namespace == var.service_account_name ?
  [var.service_account_name] : ["${var.service_account_name}@${var.service_account_namespace}"]))

  # The standard module does not allow @ but we want it
  regex_replace_chars = "/[^-a-zA-Z0-9@_]/"

  context = module.this.context
}

resource "aws_iam_role" "service_account" {
  for_each           = toset(compact([module.service_account_label.id]))
  name               = each.value
  description        = "Role assumed by Kubernetes ServiceAccount ${var.service_account_namespace}:${var.service_account_name}"
  assume_role_policy = data.aws_iam_policy_document.service_account_assume_role[each.value].json
  tags               = module.service_account_label.tags
}

data "aws_iam_policy_document" "service_account_assume_role" {
  for_each = toset(compact([module.service_account_label.id]))
  statement {
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [format("arn:%s:iam::%s:oidc-provider/%s", var.aws_partition, var.aws_account_number, local.eks_cluster_oidc_issuer)]
    }

    condition {
      test     = "StringEquals"
      values   = [format("system:serviceaccount:%s:%s", var.service_account_namespace, var.service_account_name)]
      variable = format("%s:sub", local.eks_cluster_oidc_issuer)
    }
  }
}

resource "aws_iam_policy" "service_account" {
  for_each    = toset(compact([module.service_account_label.id]))
  name        = each.value
  description = format("Grant permissions to EKS service account: %s", var.service_account_name)
  policy      = coalesce(var.aws_iam_policy_document, "{}")
}

resource "aws_iam_role_policy_attachment" "service_account" {
  for_each   = toset(compact([module.service_account_label.id]))
  role       = aws_iam_role.service_account[each.value].name
  policy_arn = aws_iam_policy.service_account[each.value].arn
}
