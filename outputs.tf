output "service_account_namespace" {
  value       = local.enabled ? var.service_account_namespace : null
  description = "Kubernetes Service Account namespace"
}

output "service_account_name" {
  value       = local.enabled ? var.service_account_name : null
  description = "Kubernetes Service Account name"
}

output "service_account_role_name" {
  value       = local.enabled ? aws_iam_role.service_account[0].name : null
  description = "IAM role name"
}

output "service_account_role_unique_id" {
  value       = local.enabled ? aws_iam_role.service_account[0].unique_id : null
  description = "IAM role unique ID"
}

output "service_account_role_arn" {
  value       = local.enabled ? aws_iam_role.service_account[0].arn : null
  description = "IAM role ARN"
}

output "service_account_policy_name" {
  value       = local.iam_policy_enabled ? aws_iam_policy.service_account[0].name : null
  description = "IAM policy name"
}

output "service_account_policy_id" {
  value       = local.iam_policy_enabled ? aws_iam_policy.service_account[0].id : null
  description = "IAM policy ID"
}

output "service_account_policy_arn" {
  value       = local.iam_policy_enabled ? aws_iam_policy.service_account[0].arn : null
  description = "IAM policy ARN"
}
