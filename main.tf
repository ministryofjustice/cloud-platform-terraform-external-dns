locals {
  external_dns_version = "2.6.4"
}

resource "helm_release" "external_dns" {
  name      = "external-dns"
  chart     = "stable/external-dns"
  namespace = "kube-system"
  version   = local.external_dns_version

  values = [templatefile("${path.module}/templates/values.yaml.tpl", {
    domainFilters = lookup(var.cluster_r53_domainfilters, terraform.workspace, [var.cluster_domain_name])
    iam_role      = aws_iam_role.externaldns.name
    cluster       = terraform.workspace
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
