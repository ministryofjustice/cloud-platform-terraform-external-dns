variable "dependence_deploy" {
  description = "Deploy Module dependence in order to be executed (deploy resource is the helm init)"
}

variable "dependence_opa" {
  description = "OPA module dependences in order to be executed."
}

variable "iam_role_nodes" {
  description = "Nodes IAM role ARN in order to create the KIAM/Kube2IAM"
  type        = string
}

variable "cluster_domain_name" {
  description = "The cluster domain used for externalDNS annotations and certmanager"
}

variable "hostzone" {
  description = "In order to solve ACME Challenges certmanager creates DNS records. We should limit the scope to certain hostzone. If star (*) is used certmanager will control all hostzones"
  type        = list(string)
  
}

# EKS variables
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
