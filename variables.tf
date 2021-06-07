variable "dependence_kiam" {
  description = "Kiam Module dependence in order to be executed"
}

variable "cluster_domain_name" {
  description = "The cluster domain used for externalDNS"
}

variable "hostzone" {
  type = list(string)
}

variable "iam_role_nodes" {
  description = "Nodes IAM role ARN in order to create the KIAM/Kube2IAM"
  type        = string
}

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
