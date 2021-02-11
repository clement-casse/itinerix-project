terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">=3.56.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }

    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.7.1"
    }
  }
}