provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

module "autoscaler_role" {
  source = "../.."

  # Singular Service Account attachment
  service_account_name      = "autoscaler"
  service_account_namespace = "kube-system"

  aws_account_number = data.aws_caller_identity.current.account_id
  # Rather than create a whole cluster, just fake the OIDC URL
  # eks_cluster_oidc_issuer_url = module.eks_cluster.eks_cluster_identity_oidc_issuer
  eks_cluster_oidc_issuer_url = "https://oidc.eks.us-west-2.amazonaws.com/id/FEDCBA9876543210FEDCBA9876543210"
  aws_iam_policy_document     = [data.aws_iam_policy_document.autoscaler.json]

  context = module.this.context
}

module "autoscaler_role_multiple_service_accounts" {
  source     = "../.."
  attributes = ["multiple", "sa"]

  # Usually there is no need to add both service account methods of attachment.
  # If you add both, they are joined via AND.
  # See https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_multi-value-conditions.html#reference_policies_multiple-conditions-eval

  # Multiple Service Account attachments
  service_account_namespace_name_list = [
    "kube-system:autoscaler",
    "default:foo",
  ]
  service_account_list_qualifier = "ForAnyValue"

  aws_account_number = data.aws_caller_identity.current.account_id
  # Rather than create a whole cluster, just fake the OIDC URL
  # eks_cluster_oidc_issuer_url = module.eks_cluster.eks_cluster_identity_oidc_issuer
  eks_cluster_oidc_issuer_url = "https://oidc.eks.us-west-2.amazonaws.com/id/FEDCBA9876543210FEDCBA9876543210"
  aws_iam_policy_document     = [data.aws_iam_policy_document.autoscaler.json]

  context = module.this.context
}
data "aws_iam_policy_document" "autoscaler" {
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
  arn = module.autoscaler_role.service_account_policy_arn
}

module "cert-manager_role" {
  source = "../.."

  attributes = ["blue"]

  service_account_name      = "cert-manager"
  service_account_namespace = "cert-manager"

  aws_account_number = data.aws_caller_identity.current.account_id
  # Rather than create a whole cluster, just fake the OIDC URL
  # eks_cluster_oidc_issuer_url = module.eks_cluster.eks_cluster_identity_oidc_issuer
  eks_cluster_oidc_issuer_url = "https://oidc.eks.us-west-2.amazonaws.com/id/FEDCBA9876543210FEDCBA9876543210"
  aws_iam_policy_document     = [data.aws_iam_policy_document.cert-manager.json]

  context = module.this.context
}

data "aws_iam_policy_document" "cert-manager" {
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
  arn = module.cert-manager_role.service_account_policy_arn
}
