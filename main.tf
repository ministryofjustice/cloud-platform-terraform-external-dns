locals {
  external_dns_version = "2.6.4"
}

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  chart      = "external-dns"
  repository = data.helm_repository.stable.metadata[0].name
  namespace  = "kube-system"
  version    = local.external_dns_version

  values = [templatefile("${path.module}/templates/values.yaml.tpl", {
    domainFilters = lookup(var.cluster_r53_domainfilters, terraform.workspace, [var.cluster_domain_name])

    cluster             = terraform.workspace
    iam_role            = var.eks ? "" : aws_iam_role.external_dns.0.name
    eks                 = var.eks
    eks_service_account = module.iam_assumable_role_admin.this_iam_role_arn
  })]

  depends_on = [
    var.dependence_kiam,
    var.dependence_deploy
  ]


  lifecycle {
    ignore_changes = [keyring]
  }
}
