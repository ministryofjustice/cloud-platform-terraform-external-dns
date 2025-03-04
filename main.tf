
resource "helm_release" "external_dns" {
  name       = "external-dns"
  chart      = "external-dns"
  repository = "oci://registry-1.docker.io/bitnamicharts"
  namespace  = "kube-system"
  version    = "8.7.2"

  values = [templatefile("${path.module}/templates/values.yaml.tpl", {
    domainFilters = var.domain_filters

    # For production clusters, we are excluding test cluster domains from being considered by external-dns
    productionRegexDomainFilter = var.is_live_cluster ? ".*" : ""
    productionRegexDomainExclusion = var.is_live_cluster ? "cp-.*-.*\\.cloud-platform\\.service\\.justice\\.gov\\.uk$|yy-.*-.*\\.cloud-platform\\.service\\.justice\\.gov\\.uk$" : ""

    # Set route53 sync interval and zone caching based on whether this is a production cluster or not
    sync_interval = var.is_live_cluster ? "10m" : "60m"
    aws_zone_cache_duration = "2h"

    cluster             = terraform.workspace
    eks_service_account = module.iam_assumable_role_admin.iam_role_arn
    txtPrefix           = "_external_dns.%%{record_type}." 
  })]

  set {
    name  = "resources.requests.cpu"
    value = "200m" 
  }

  set {
    name  = "resources.requests.memory"
    value = "1024Mi"
  }

  lifecycle {
    ignore_changes = [keyring]
  }
}
