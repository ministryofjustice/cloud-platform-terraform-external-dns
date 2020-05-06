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

  dependence_deploy = null_resource.deploy
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
  dependence_deploy = null_resource.deploy

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

## Inputs

| Name                        | Description                                                            | Type     | Default | Required |
|-----------------------------|---------------------------------------------------------------         |:--------:|:-------:|:--------:|
| dependence_kiam             | Kiam Dependence variable                                               | string   |         | yes      |
| dependence_deploy           | Deploy (helm) dependence variable                                      | string   |         | yes      |
| iam_role_nodes              | Nodes IAM role ARN in order to create the KIAM/Kube2IAM                | string   |         | yes      |
| hostzone                    | To solve ACME Challenges. Scope should be limited to hostzone.         | string   |         | yes      |
| cluster_domain_name         | Value used for externalDNS annotations and certmanager                 | string   |         | yes      |
| eks                         | Are we deploying in EKS or not?                                        | bool     | false   | no       |
| eks_cluster_oidc_issuer_url | The OIDC issuer URL from the cluster, used for IAM ServiceAccount      | string   |         | no       |


## Outputs

| Name | Description |
|------|-------------|
