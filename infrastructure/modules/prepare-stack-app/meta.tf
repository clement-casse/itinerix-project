terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
      version = ">= 1.10.0"
    }
  }
}