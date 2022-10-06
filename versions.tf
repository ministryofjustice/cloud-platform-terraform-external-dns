terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    helm = {
      source  = "hashicorp/helm"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
    }
  }
}
