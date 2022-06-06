locals {
  domainfilters = {
    live    = [""]
    manager = ["manager.cloud-platform.service.justice.gov.uk.", "cloud-platform.service.justice.gov.uk.", "integrationtest.service.justice.gov.uk."]
    default = [var.cluster_domain_name, "integrationtest.service.justice.gov.uk."]
  }
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  chart      = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  namespace  = "kube-system"
  version    = "6.5.2"

  values = [templatefile("${path.module}/templates/values.yaml.tpl", {
    domainFilters = lookup(local.domainfilters, terraform.workspace, local.domainfilters["default"])

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
