
resource "helm_release" "external_dns" {
  name       = "external-dns"
  chart      = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  namespace  = "kube-system"
  version    = "6.20.1"

  values = [templatefile("${path.module}/templates/values.yaml.tpl", {
    domainFilters = var.domain_filters

    # For production clusters, we are excluding test cluster domains from being considered by external-dns
    productionRegexDomainFilter = var.enable_test_cluster_filters ? ".*" : ""
    productionRegexDomainExclusion = var.enable_test_cluster_filters ? "cp-.*-.*\\.cloud-platform\\.service\\.justice\\.gov\\.uk$|yy-.*-.*\\.cloud-platform\\.service\\.justice\\.gov\\.uk$" : ""

    cluster             = terraform.workspace
    eks_service_account = module.iam_assumable_role_admin.this_iam_role_arn
  })]

  lifecycle {
    ignore_changes = [keyring]
  }
}
