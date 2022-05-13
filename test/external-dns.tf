module "alert-manger" {
  source = "../"

  cluster_domain_name = "cert-manager.cloud-platform.service.justice.gov.uk"
  hostzone            = ["AAATEST"]

  dependence_prometheus = "ignore"
}
