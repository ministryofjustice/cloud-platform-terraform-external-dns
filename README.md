# cloud-platform-terraform-external-dns

Terraform module that deploys cloud-platform external-dns.

## Usage

```hcl
module "external_dns" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-external-dns?ref=1.0.2"

  cluster_domain_name = data.terraform_remote_state.cluster.outputs.cluster_domain_name
  hostzone            = lookup(var.cluster_r53_resource_maps, terraform.workspace, [data.aws_route53_zone.selected.zone_id])
  eks_cluster_oidc_issuer_url = data.terraform_remote_state.cluster.outputs.cluster_oidc_issuer_url
}
```


<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| kubectl | 1.11.2 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| helm | n/a |
| kubectl | 1.11.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| iam_assumable_role_admin | terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc | 3.13.0 |

## Resources

| Name |
|------|
| [aws_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) |
| [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) |
| [helm_release](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) |
| [kubectl_manifest](https://registry.terraform.io/providers/gavinbunney/kubectl/1.11.2/docs/resources/manifest) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_domain\_name | The cluster domain used for externalDNS | `any` | n/a | yes |
| dependence\_prometheus | Prometheus module dependences in order to be executed. | `any` | n/a | yes |
| eks\_cluster\_oidc\_issuer\_url | This is going to be used when we create the IAM OIDC role | `string` | `""` | no |
| hostzone | n/a | `list(string)` | n/a | yes |

## Outputs

No output.

<!--- END_TF_DOCS --->

