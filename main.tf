locals {
  external_dns_version = "2.6.4"
  live_workspace       = "live-1"
}

resource "helm_release" "external_dns" {
  name      = "external-dns"
  chart     = "stable/external-dns"
  namespace = "kube-system"
  version   = local.external_dns_version

  values = [templatefile("${path.module}/templates/values.yaml.tpl", {
    domainFilters = lookup(var.cluster_r53_domainfilters, terraform.workspace, [var.cluster_domain_name])

    cluster             = terraform.workspace
    iam_role            = var.eks ? "" : aws_iam_role.external_dns.0.name
    eks                 = var.eks
    eks_service_account = module.iam_assumable_role_admin.this_iam_role_arn
  })]

  depends_on = [
    var.dependence_kiam,
    var.dependence_deploy,
    # TODO: Remove prometheus dependency
    # var.dependence_prometheus,
    # var.dependence_opa
  ]


  lifecycle {
    ignore_changes = [keyring]
  }
}
