terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.24.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">=2.6.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">=1.13.2"
    }
  }
}
