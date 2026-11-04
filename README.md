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

## Gateway API HTTPRoute discovery

The `gateway-api-httproute` branch retains Service and Ingress discovery and adds
`gateway-httproute`. It keeps chart `9.0.3`, the existing ExternalDNS `0.18.0`
image, Route53 permissions, domain filters, sync policy and TXT ownership
settings unchanged.

Use the branch as the module source:

```hcl
source = "github.com/ministryofjustice/cloud-platform-terraform-external-dns?ref=gateway-api-httproute"
```

Install the Gateway API CRDs before upgrading ExternalDNS in each cluster.
ExternalDNS `0.18.0` uses the served `v1beta1` Gateway and HTTPRoute APIs, even
when manifests use `v1`. The Gateway API `v1.6.1` CRDs bundled with Envoy Gateway
`v1.9.3` serve both versions. Check this compatibility when upgrading CRDs.
The existing chart's ClusterRole and binding already grant read access to
Gateways, HTTPRoutes and namespaces; no additional RBAC resources are needed.

DNS names come from `HTTPRoute.spec.hostnames`, intersected with the parent
Gateway listener's hostname. The route must be accepted by the Gateway and the
Gateway must expose an address in its status. A Service hostname annotation is
not needed for this flow. Keep DNS names within the existing domain filters
and permitted Route53 zones.

For an existing Service-based DNS record, establish the accepted HTTPRoute
before removing its Service hostname annotation. Existing Service/Ingress
sources must remain enabled to preserve current NGINX DNS records.

Run `terraform init -backend=false`, `terraform validate` and `terraform test`
to check the module. Native mocked tests require Terraform >= 1.7 and do not
deploy resources.


<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=4.24.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >=2.6.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >=1.13.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >=4.24.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >=2.6.0 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | >=1.13.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_iam_assumable_role_admin"></a> [iam\_assumable\_role\_admin](#module\_iam\_assumable\_role\_admin) | terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc | 3.13.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.external_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [helm_release.external_dns](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubectl_manifest.test](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [aws_iam_policy_document.external_dns_irsa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_domain_name"></a> [cluster\_domain\_name](#input\_cluster\_domain\_name) | The cluster domain used for externalDNS | `any` | n/a | yes |
| <a name="input_domain_filters"></a> [domain\_filters](#input\_domain\_filters) | n/a | `list(string)` | n/a | yes |
| <a name="input_eks_cluster_oidc_issuer_url"></a> [eks\_cluster\_oidc\_issuer\_url](#input\_eks\_cluster\_oidc\_issuer\_url) | This is going to be used when we create the IAM OIDC role | `string` | `""` | no |
| <a name="input_hostzones"></a> [hostzones](#input\_hostzones) | n/a | `list(string)` | n/a | yes |

## Outputs

No outputs.

<!--- END_TF_DOCS --->


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=4.24.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >=3.0.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >=4.24.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >=3.0.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_iam_assumable_role_admin"></a> [iam\_assumable\_role\_admin](#module\_iam\_assumable\_role\_admin) | terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc | 5.52.1 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.external_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [helm_release.external_dns](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [aws_iam_policy_document.external_dns_irsa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_domain_name"></a> [cluster\_domain\_name](#input\_cluster\_domain\_name) | The cluster domain used for externalDNS | `any` | n/a | yes |
| <a name="input_domain_filters"></a> [domain\_filters](#input\_domain\_filters) | n/a | `list(string)` | n/a | yes |
| <a name="input_eks_cluster_oidc_issuer_url"></a> [eks\_cluster\_oidc\_issuer\_url](#input\_eks\_cluster\_oidc\_issuer\_url) | This is going to be used when we create the IAM OIDC role | `string` | `""` | no |
| <a name="input_hostzones"></a> [hostzones](#input\_hostzones) | n/a | `list(string)` | n/a | yes |
| <a name="input_is_live_cluster"></a> [is\_live\_cluster](#input\_is\_live\_cluster) | For assigning chart values based on the cluster type | `bool` | `true` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
