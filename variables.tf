variable "service_account_name" {
  type        = string
  description = "Kubernetes ServiceAccount name"
}

variable "service_account_namespace" {
  type        = string
  description = "Kubernetes Namespace where service account is deployed"
}

variable "aws_account_number" {
  type        = string
  description = "AWS account number of EKS cluster owner"
}

variable "aws_partition" {
  type        = string
  default     = "aws"
  description = "AWS partition: 'aws', 'aws-cn', or 'aws-us-gov'"
}

variable "aws_iam_policy_document" {
  type        = string
  description = "JSON string representation of the IAM policy for this service account"
}

variable "eks_cluster_oidc_issuer_url" {
  type        = string
  description = "OIDC issuer URL for the EKS cluster (initial \"https://\" may be omitted)"
}
