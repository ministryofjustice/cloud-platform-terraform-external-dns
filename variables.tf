variable "cluster_domain_name" {
  description = "The cluster domain used for externalDNS"
}

variable "hostzones" {
  type = list(string)
}

variable "domain_filters" {
  type = list(string)
}

variable "eks_cluster_oidc_issuer_url" {
  description = "This is going to be used when we create the IAM OIDC role"
  type        = string
  default     = ""
}
