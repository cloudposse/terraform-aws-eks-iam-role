provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

module "autoscaler_role" {
  source = "../.."

  service_account_name      = "autoscaler"
  service_account_namespace = "kube-system"

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
