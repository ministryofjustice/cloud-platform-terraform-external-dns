
resource "helm_release" "external_dns" {
  name       = "external-dns"
  chart      = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  namespace  = "kube-system"
  version    = "6.4.4"

  values = [templatefile("${path.module}/templates/values.yaml.tpl", {
    domainFilters = var.domain_filters

    cluster             = terraform.workspace
    eks_service_account = module.iam_assumable_role_admin.this_iam_role_arn
  })]

  depends_on = [
    var.dependence_prometheus
  ]

  lifecycle {
    ignore_changes = [keyring]
  }
}

resource "kubectl_manifest" "test" {
  yaml_body = file("${path.module}/resources/alerts.yaml")

  depends_on = [helm_release.external_dns]
}
