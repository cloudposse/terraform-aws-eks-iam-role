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
| aws\_partition | AWS partition: 'aws', 'aws-cn', or 'aws-us-gov' | `string` | `"aws"` | no |
| delimiter | Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes` | `string` | `"-"` | no |
| eks\_cluster\_oidc\_issuer\_url | OIDC issuer URL for the EKS cluster (initial "https://" may be omitted) | `string` | n/a | yes |
| enabled | Set false to prevent creation of resources | `bool` | `true` | no |
| environment | Environment, e.g. 'ue2', 'us-east-2', OR 'prod', 'staging', 'dev', 'pre-prod', 'UAT' | `string` | `""` | no |
| name | Solution name, e.g. 'app' or 'jenkins' | `string` | `""` | no |
| namespace | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | `""` | no |
| service\_account\_name | Kubernetes ServiceAccount name | `string` | n/a | yes |
| service\_account\_namespace | Kubernetes Namespace where service account is deployed | `string` | n/a | yes |
| stage | Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release' | `string` | `""` | no |
| tags | Additional tags (e.g. `map('BusinessUnit','XYZ')` | `map(string)` | `{}` | no |

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

