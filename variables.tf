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
  default     = null
  description = "AWS account number of EKS cluster owner. If an AWS account number is not provided, the current aws provider account number will be used."
}

variable "aws_partition" {
  type        = string
  default     = "aws"
  description = "AWS partition: 'aws', 'aws-cn', or 'aws-us-gov'"
}

variable "aws_iam_policy_document" {
  type        = list(string)
  default     = []
  description = "JSON string representation of the IAM policy for this service account"

  validation {
    condition     = length(var.aws_iam_policy_document) < 2
    error_message = "Only 1 IAM policy document can be added."
  }
}

variable "eks_cluster_oidc_issuer_url" {
  type        = string
  description = "OIDC issuer URL for the EKS cluster (initial \"https://\" may be omitted)"
}
