terraform {
  # Function [`one()`](https://www.terraform.io/docs/language/functions/one.html) requires terraform v0.15+. 
  # to extract output from either linkerd or istio mpdule
  required_version = ">= 0.15"

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