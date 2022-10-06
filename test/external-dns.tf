module "alert-manger" {
  source = "../"

  cluster_domain_name = "cert-manager.cloud-platform.service.justice.gov.uk"
  hostzones           = ["AAATEST"]
  domain_filters      = ["AAATEST"]

  dependence_prometheus = "ignore"
}
