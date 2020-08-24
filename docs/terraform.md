## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.0, < 0.14.0 |
| aws | ~> 2.0 |
| local | ~> 1.2 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| attributes | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| aws\_account\_number | AWS account number of EKS cluster owner | `string` | n/a | yes |
| aws\_iam\_policy\_document | JSON string representation of the IAM policy for this service account | `string` | n/a | yes |
| delimiter | Delimiter to be used between `name`, `namespace`, `stage`, etc. | `string` | `"-"` | no |
| eks\_cluster\_oidc\_issuer\_url | OIDC issuer URL for the EKS cluster (initial "https://" may be omitted) | `string` | n/a | yes |
| enabled | Set false to prevent creation of resources | `bool` | `true` | no |
| environment | Region, e.g. 'uw2', 'uw1', 'en1', 'gbl' | `string` | n/a | yes |
| name | Solution name, e.g. 'app' or 'cluster' | `string` | n/a | yes |
| namespace | Namespace, which could be your organization name, e.g. 'eg' or 'cp' | `string` | n/a | yes |
| service\_account\_name | Kubernetes ServiceAccount name | `string` | n/a | yes |
| service\_account\_namespace | Kubernetes Namespace where service account is deployed | `string` | n/a | yes |
| stage | Stage, e.g. 'prod', 'staging', 'dev', 'testing' | `string` | n/a | yes |
| tags | Additional tags (e.g. `map('BusinessUnit`,`XYZ`) | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| service\_account\_name | Kubernetes Service Account name |
| service\_account\_namespace | Kubernetes Service Account namespace |
| service\_account\_policy\_arn | IAM policy ARN |
| service\_account\_policy\_id | IAM policy ID |
| service\_account\_policy\_name | IAM policy name |
| service\_account\_role\_arn | IAM role ARN |
| service\_account\_role\_name | IAM role name |
| service\_account\_role\_unique\_id | IAM role unique ID |

