locals {
  domainfilters = {
    live-1  = [""]
    manager = ["manager.cloud-platform.service.justice.gov.uk.", "cloud-platform.service.justice.gov.uk.", "integrationtest.service.justice.gov.uk."]
    default = [var.cluster_domain_name, "integrationtest.service.justice.gov.uk."]
  }
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  chart      = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  namespace  = "kube-system"
  version    = "4.10.0"

  values = [templatefile("${path.module}/templates/values.yaml.tpl", {
    domainFilters = lookup(local.domainfilters, terraform.workspace, local.domainfilters["default"])

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
