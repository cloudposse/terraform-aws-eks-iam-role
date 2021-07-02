locals {
  enabled = module.this.enabled

  eks_cluster_oidc_issuer = replace(var.eks_cluster_oidc_issuer_url, "https://", "")

  # If both var.service_account_namespace and var.service_account_name are provided,
  # then the role ARM will have one of the following formats:
  # 1. if var.service_account_namespace != var.service_account_name: arn:aws:iam::<account_number>:role/<namespace>-<environment>-<stage>-<optional_name>-<service_account_name>@<service_account_namespace>
  # 2. if var.service_account_namespace == var.service_account_name: arn:aws:iam::<account_number>:role/<namespace>-<environment>-<stage>-<optional_name>-<service_account_name>

  # 3. If var.service_account_namespace == "" and var.service_account_name is provided,
  # then the role ARM will have format arn:aws:iam::<account_number>:role/<namespace>-<environment>-<stage>-<optional_name>-<service_account_name>@all,
  # and the policy will use a wildcard for the namespace in the test condition to allow ServiceAccounts in any Kubernetes namespace to assume the role (useful for unlimited preview environments)

  # 4. If var.service_account_name == "" and var.service_account_namespace is provided,
  # then the role ARM will have format arn:aws:iam::<account_number>:role/<namespace>-<environment>-<stage>-<optional_name>-all@<service_account_namespace>,
  # and the policy will use a wildcard for the service account name in the test condition to allow any ServiceAccount in the given namespace to assume the role.
  # For more details, see https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts-technical-overview.html#iam-role-configuration

  # 5. If both var.service_account_name == "" and var.service_account_namespace == "",
  # then the role ARM will have format arn:aws:iam::<account_number>:role/<namespace>-<environment>-<stage>-<optional_name>-all@all,
  # and the policy will use wildcards for both the namespace and the service account name in the test condition to allow all ServiceAccounts
  # in all Kubernetes namespaces to assume the IAM role (not recommended).

  service_account_long_id = format("%v@%v", coalesce(var.service_account_name, "all"), coalesce(var.service_account_namespace, "all"))
  service_account_id      = trimsuffix(local.service_account_long_id, format("@%v", var.service_account_name))
  
  policy = coalesce(var.aws_iam_policy_document, "{}")
}

module "service_account_label" {
  source  = "cloudposse/label/null"
  version = "0.24.1"

  # To remain consistent with our other modules, the service account name goes after
  # user-supplied attributes, not before.
  attributes = [local.service_account_id]

  # The standard module does not allow @ but we want it
  regex_replace_chars = "/[^-a-zA-Z0-9@_]/"

  context = module.this.context
}

resource "aws_iam_role" "service_account" {
  for_each           = toset(compact([module.service_account_label.id]))
  name               = each.value
  description        = format("Role assumed by EKS ServiceAccount %s", local.service_account_id)
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
      test     = "StringLike"
      values   = [format("system:serviceaccount:%s:%s", coalesce(var.service_account_namespace, "*"), coalesce(var.service_account_name, "*"))]
      variable = format("%s:sub", local.eks_cluster_oidc_issuer)
    }
  }
}

# managed IAM policy

resource "aws_iam_policy" "service_account" {
  for_each    = var.managed_iam_policy ? toset(compact([module.service_account_label.id])) : []
  name        = each.value
  description = format("Grant permissions to EKS ServiceAccount %s", local.service_account_id)
  policy      = local.policy
}

resource "aws_iam_role_policy_attachment" "service_account" {
  for_each   = var.managed_iam_policy ? toset(compact([module.service_account_label.id])) : []
  role       = aws_iam_role.service_account[each.value].name
  policy_arn = aws_iam_policy.service_account[each.value].arn
}

# inline IAM policy

resource "aws_iam_role_policy" "service_account" {
  for_each = var.managed_iam_policy == false ? toset(compact([module.service_account_label.id])) : []
  role     = aws_iam_role.service_account[each.value].name
  policy   = local.policy
}
