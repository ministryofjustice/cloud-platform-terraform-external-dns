
# DEPENDENCIES

# TODO: Remove Prometheus dependency
# variable "dependence_prometheus" {
#   description = "Prometheus module dependence in order to be executed."
# }

variable "dependence_deploy" {
  description = "Deploy Module dependence in order to be executed (deploy resource is the helm init)"
}

variable "dependence_kiam" {
  description = "Kiam Module dependence in order to be executed"
}

# variable "dependence_opa" {
#   description = "OPA module dependences in order to be executed."
# }

# EXTERNAL-DNS

variable "cluster_r53_domainfilters" {
  default = {
    live-1  = [""]
    manager = ["manager.cloud-platform.service.justice.gov.uk.", "cloud-platform.service.justice.gov.uk."]
  }
}

variable "cluster_domain_name" {
  description = "The cluster domain used for externalDNS"
}

variable "hostzone" {
  type = list(string)
}

# IAM ROLES
variable "iam_role_nodes" {
  description = "Nodes IAM role ARN in order to create the KIAM/Kube2IAM"
  type        = string
}

# EKS VARIABLES

variable "eks" {
  description = "Where are you applying this modules in kOps cluster or in EKS (KIAM or KUBE2IAM?)"
  type        = bool
  default     = false
}

variable "eks_cluster_oidc_issuer_url" {
  description = "If EKS variable is set to true this is going to be used when we create the IAM OIDC role"
  type        = string
  default     = ""
}
