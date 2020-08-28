output "autoscaler_role" {
  value = module.autoscaler_role.service_account_role_name
}

output "autoscaler_policy" {
  value = data.aws_iam_policy.autoscaler.policy
}

output "cert-manager_role" {
  value = module.cert-manager_role.service_account_role_name
}

output "cert-manager_policy" {
  value = data.aws_iam_policy.cert-manager.policy
}
