variable "service_account_name" {
  type        = string
  description = "Kubernetes ServiceAccount name"
  default     = null
}

variable "service_account_namespace" {
  type        = string
  description = "Kubernetes Namespace where service account is deployed"
  default     = null
}

variable "service_account_list_qualifier" {
  type        = string
  description = "Kubernetes ServiceAccount list qualifier, must be one of `ForAllValues` or `ForAnyValue`"
  validation {
    condition     = contains(["ForAllValues", "ForAnyValue"], var.service_account_list_qualifier)
    error_message = "Kubernetes ServiceAccount list qualifier must be one of `ForAllValues` or `ForAnyValue`."
  }
  default = "ForAnyValue"
}

variable "service_account_namespace_name_list" {
  type        = list(string)
  description = "List of `namespace:name` for service account assume role IAM policy"
  default     = null
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
  type        = any
  default     = []
  description = <<-EOT
    JSON string representation of the IAM policy for this service account as list of string (0 or 1 items).
    If empty, no custom IAM policy document will be used. If the list contains a single document, a custom
    IAM policy will be created and attached to the IAM role.
    Can also be a plain string, but that use is DEPRECATED because of Terraform issues.
    EOT
}

variable "eks_cluster_oidc_issuer_url" {
  type        = string
  description = "OIDC issuer URL for the EKS cluster (initial \"https://\" may be omitted)"

  validation {
    condition     = length(var.eks_cluster_oidc_issuer_url) > 0
    error_message = "The eks_cluster_oidc_issuer_url value must have a value."
  }
}

variable "permissions_boundary" {
  type        = string
  description = "ARN of the policy that is used to set the permissions boundary for the role."
  default     = null
}
