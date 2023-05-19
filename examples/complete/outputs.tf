output "autoscaler_role" {
  value       = module.autoscaler_role.service_account_role_name
  description = "The name of the IAM role for the autoscaler service account"
}

output "autoscaler_policy" {
  value       = one(data.aws_iam_policy.autoscaler[*].policy)
  description = "The IAM policy for the autoscaler service account"
}

output "multiple_service_accounts_role_short" {
  value       = module.multiple_service_accounts_short.service_account_role_name
  description = "The name of the IAM role for the multiple_service_accounts_short test case"
}

output "multiple_service_accounts_role_long" {
  value       = module.multiple_service_accounts_long.service_account_role_name
  description = "The name of the IAM role for the multiple_service_accounts_long test case"
}

output "cert-manager_role" {
  value       = module.cert-manager_role.service_account_role_name
  description = "The name of the IAM role for the cert-manager service account"
}

output "cert-manager_policy" {
  value       = one(data.aws_iam_policy.cert-manager[*].policy)
  description = "The IAM policy for the cert-manager service account"
}
