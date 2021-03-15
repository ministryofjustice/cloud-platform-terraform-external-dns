locals {
  external_dns_version = "3.1.0"
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  chart      = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
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
    var.dependence_kiam
  ]


  lifecycle {
    ignore_changes = [keyring]
  }
}
