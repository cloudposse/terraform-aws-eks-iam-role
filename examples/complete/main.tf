provider "aws" {
  region = var.region
}

locals {
  enabled = module.this.enabled
}

data "aws_caller_identity" "current" {
  count = local.enabled ? 1 : 0
}

module "autoscaler_role" {
  source = "../.."

  # Singular Service Account attachment
  service_account_name      = "autoscaler"
  service_account_namespace = "kube-system"

  aws_account_number = one(data.aws_caller_identity.current[*].account_id)
  # Rather than create a whole cluster, just fake the OIDC URL
  # eks_cluster_oidc_issuer_url = module.eks_cluster.eks_cluster_identity_oidc_issuer
  eks_cluster_oidc_issuer_urls = ["https://oidc.eks.us-west-2.amazonaws.com/id/FEDCBA9876543210FEDCBA9876543210"]
  aws_iam_policy_document     = [one(data.aws_iam_policy_document.autoscaler[*].json)]

  context = module.this.context
}

module "multiple_service_accounts_short" {
  source = "../.."

  # Test the rare case multiple service accounts are attached to the same role
  # Multiple Service Account attachments
  service_account_namespace_name_list = [
    "app:app",
    "pr-*:app",
  ]

  aws_account_number = one(data.aws_caller_identity.current[*].account_id)
  # Rather than create a whole cluster, just fake the OIDC URL
  # eks_cluster_oidc_issuer_url = module.eks_cluster.eks_cluster_identity_oidc_issuer
  eks_cluster_oidc_issuer_urls = ["https://oidc.eks.us-west-2.amazonaws.com/id/FEDCBA9876543210FEDCBA9876543210"]
  aws_iam_policy_document     = [one(data.aws_iam_policy_document.autoscaler[*].json)]

  context = module.this.context
}
data "aws_iam_policy_document" "autoscaler" {
  #bridgecrew:skip=BC_AWS_IAM_57:Skipping `Ensure IAM policies does not allow write access without constraint` because this is a test case
  count = local.enabled ? 1 : 0

  statement {
    sid = "AllowToScaleEKSNodeGroupAutoScalingGroup"

    actions = [
      "ec2:DescribeLaunchTemplateVersions",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:DescribeTags",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeAutoScalingGroups"
    ]

    effect    = "Allow"
    resources = ["*"]
  }
}

data "aws_iam_policy" "autoscaler" {
  count = local.enabled ? 1 : 0

  arn = module.autoscaler_role.service_account_policy_arn
}

module "multiple_service_accounts_long" {
  source = "../.."

  # Test the rare case multiple service accounts are attached to the same role
  # Multiple Service Account attachments
  service_account_namespace_name_list = [
    "very-long-namespace:even-longer-service-account-name",
    "app:app",
  ]

  aws_account_number = one(data.aws_caller_identity.current[*].account_id)
  # Rather than create a whole cluster, just fake the OIDC URL
  # eks_cluster_oidc_issuer_url = module.eks_cluster.eks_cluster_identity_oidc_issuer
  eks_cluster_oidc_issuer_urls = ["https://oidc.eks.us-west-2.amazonaws.com/id/FEDCBA9876543210FEDCBA9876543210"]
  aws_iam_policy_document     = [one(data.aws_iam_policy_document.autoscaler[*].json)]

  context = module.this.context
}

module "cert-manager_role" {
  source = "../.."

  attributes = ["blue"]

  service_account_name      = "cert-manager"
  service_account_namespace = "cert-manager"

  aws_account_number = one(data.aws_caller_identity.current[*].account_id)
  # Rather than create a whole cluster, just fake the OIDC URL
  # eks_cluster_oidc_issuer_url = module.eks_cluster.eks_cluster_identity_oidc_issuer
  eks_cluster_oidc_issuer_urls = ["https://oidc.eks.us-west-2.amazonaws.com/id/FEDCBA9876543210FEDCBA9876543210"]
  aws_iam_policy_document     = [one(data.aws_iam_policy_document.cert-manager[*].json)]

  context = module.this.context
}

data "aws_iam_policy_document" "cert-manager" {
  #bridgecrew:skip=BC_AWS_IAM_57:Skipping `Ensure IAM policies does not allow write access without constraint` because this is a test case
  count = local.enabled ? 1 : 0

  statement {
    sid = "GrantListHostedZonesListResourceRecordSets"

    actions = [
      "route53:ListHostedZonesByName"
    ]

    effect    = "Allow"
    resources = ["*"]
  }
}

data "aws_iam_policy" "cert-manager" {
  count = local.enabled ? 1 : 0
  arn   = module.cert-manager_role.service_account_policy_arn
}
