# cloud-platform-terraform-external-dns

Terraform module that deploys cloud-platform external-dns.

## Usage

```hcl
# For KOps clusters
module "external_dns" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-external-dns?ref=1.0.1"

  iam_role_nodes      = data.aws_iam_role.nodes.arn
  cluster_domain_name = data.terraform_remote_state.cluster.outputs.cluster_domain_name
  hostzone            = lookup(var.cluster_r53_resource_maps, terraform.workspace, ["arn:aws:route53:::hostedzone/${data.terraform_remote_state.cluster.outputs.hosted_zone_id}"])

  dependence_kiam   = helm_release.kiam

  # This section is for EKS
  eks = false
}

# For EKS clusters
module "external_dns" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-external-dns?ref=1.0.2"

  iam_role_nodes      = data.aws_iam_role.nodes.arn
  cluster_domain_name = data.terraform_remote_state.cluster.outputs.cluster_domain_name
  hostzone            = lookup(var.cluster_r53_resource_maps, terraform.workspace, [data.aws_route53_zone.selected.zone_id])

  # EKS doesn't use KIAM but it is a requirement for the module.
  dependence_kiam   = ""

  # This section is for EKS
  eks                         = true
  eks_cluster_oidc_issuer_url = data.terraform_remote_state.cluster.outputs.cluster_oidc_issuer_url
}
```

  # This module requires kiam on KOps clusters
  ```hcl
  dependence_kiam   = helm_release.kiam
  ```

  EKS doesn't use kiam so this can be replaced with an empty string.

  # This section is for EKS
  ```hcl
  eks                         = true
  eks_cluster_oidc_issuer_url = data.terraform_remote_state.cluster.outputs.cluster_oidc_issuer_url
}
  ```

<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| helm | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| iam_assumable_role_admin | terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc | 3.13.0 |

## Resources

| Name |
|------|
| [aws_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) |
| [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) |
| [aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) |
| [aws_iam_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) |
| [helm_release](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_domain\_name | The cluster domain used for externalDNS | `any` | n/a | yes |
| cluster\_r53\_domainfilters | n/a | `map` | <pre>{<br>  "live-1": [<br>    ""<br>  ],<br>  "manager": [<br>    "manager.cloud-platform.service.justice.gov.uk.",<br>    "cloud-platform.service.justice.gov.uk."<br>  ]<br>}</pre> | no |
| eks | Where are you applying this modules in kOps cluster or in EKS (KIAM or KUBE2IAM?) | `bool` | `false` | no |
| eks\_cluster\_oidc\_issuer\_url | If EKS variable is set to true this is going to be used when we create the IAM OIDC role | `string` | `""` | no |
| hostzone | n/a | `list(string)` | n/a | yes |
| iam\_role\_nodes | Nodes IAM role ARN in order to create the KIAM/Kube2IAM | `string` | n/a | yes |

## Outputs

No output.

<!--- END_TF_DOCS --->

