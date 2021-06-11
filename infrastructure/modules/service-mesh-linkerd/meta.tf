terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
      version = ">= 1.10.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
  }
}