output "autoscaler_role" {
  value = module.autoscaler_role.service_account_role_name
}

output "autoscaler_policy" {
  value = one(data.aws_iam_policy.autoscaler[*].policy)
}

output "multiple_service_accounts_role_short" {
  value = module.multiple_service_accounts_short.service_account_role_name
}

output "multiple_service_accounts_role_long" {
  value = module.multiple_service_accounts_long.service_account_role_name
}

output "cert-manager_role" {
  value = module.cert-manager_role.service_account_role_name
}

output "cert-manager_policy" {
  value = one(data.aws_iam_policy.cert-manager[*].policy)
}
