locals {
  enabled = module.this.enabled

  eks_cluster_oidc_issuer = replace(var.eks_cluster_oidc_issuer_url, "https://", "")

  # If both var.service_account_namespace and var.service_account_name are provided and not equal to "*",
  # then the role ARM will have one of the following formats:
  # - if var.service_account_namespace != var.service_account_name: arn:aws:iam::<account_number>:role/<namespace>-<environment>-<stage>-<service_account_name>@<service_account_namespace>
  # - if var.service_account_namespace == var.service_account_name: arn:aws:iam::<account_number>:role/<namespace>-<environment>-<stage>-<service_account_name>

  # If var.service_account_name is provided and not equal to "*", and var.service_account_namespace == "*",
  # then the role ARM will have format arn:aws:iam::<account_number>:role/<namespace>-<environment>-<stage>-<service_account_name>,
  # and the policy will use "StringLike" in the test condition to allow ServiceAccounts in any Kubernetes namespace to assume the role (useful for unlimited preview environments)

  # If var.service_account_name == "*",
  # then `module.this.name` must be provided (to correctly name the role and policy),
  # and the role ARM will have format arn:aws:iam::<account_number>:role/<namespace>-<environment>-<stage>-<name>,
  # and the policy will use "StringLike" in the test condition to allow to scope IAM roles to a namespace (allow different ServiceAccounts in the same namespace to assume the role)
  # For more details, see https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts-technical-overview.html#iam-role-configuration

  service_account_id = var.service_account_namespace == var.service_account_name || var.service_account_namespace == "*" ? var.service_account_name : (
    format("%s@%s", var.service_account_name, var.service_account_namespace)
  )

  attributes = var.service_account_name == "*" ? [] : [local.service_account_id]

  use_string_like_in_policy_condition = var.service_account_namespace == "*" || var.service_account_name == "*"
}

module "service_account_label" {
  source  = "cloudposse/label/null"
  version = "0.24.1"

  # To remain consistent with our other modules, the service account name goes after
  # user-supplied attributes, not before.
  attributes = local.attributes

  # The standard module does not allow @ but we want it
  regex_replace_chars = "/[^-a-zA-Z0-9@_]/"

  context = module.this.context
}

resource "aws_iam_role" "service_account" {
  for_each           = toset(compact([module.service_account_label.id]))
  name               = each.value
  description        = format("Role assumed by Kubernetes ServiceAccount %s", local.service_account_id)
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
      test     = local.use_string_like_in_policy_condition ? "StringLike" : "StringEquals"
      values   = [format("system:serviceaccount:%s:%s", var.service_account_namespace, var.service_account_name)]
      variable = format("%s:sub", local.eks_cluster_oidc_issuer)
    }
  }
}

resource "aws_iam_policy" "service_account" {
  for_each    = toset(compact([module.service_account_label.id]))
  name        = each.value
  description = format("Grant permissions to Kubernetes ServiceAccount %s", local.service_account_id)
  policy      = coalesce(var.aws_iam_policy_document, "{}")
}

resource "aws_iam_role_policy_attachment" "service_account" {
  for_each   = toset(compact([module.service_account_label.id]))
  role       = aws_iam_role.service_account[each.value].name
  policy_arn = aws_iam_policy.service_account[each.value].arn
}
