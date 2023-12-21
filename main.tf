
resource "helm_release" "external_dns" {
  name       = "external-dns"
  chart      = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  namespace  = "kube-system"
  version    = "6.10.2"

  values = [templatefile("${path.module}/templates/values.yaml.tpl", {
    domainFilters = var.domain_filters

    cluster             = terraform.workspace
    eks_service_account = module.iam_assumable_role_admin.this_iam_role_arn
  })]

  lifecycle {
    ignore_changes = [keyring]
  }
}
