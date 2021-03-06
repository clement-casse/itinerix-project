variable "k8s_host" {
  description = ""
  type        = string
}

variable "k8s_token" {
  description = ""
  type        = string
}

variable "k8s_cluster_ca_certificate" {
  description = ""
  type        = string
}

variable "project" {
  description = "The project in which to hold the components"
  type        = string
}

variable "region" {
  description = "The region in which to create the VPC network"
  type        = string
}

variable "cluster_name" {
  description = "The name to give the new Kubernetes cluster."
  type        = string
  default     = "private-cluster"
}


variable "istio_version" {
  description = "Version Number of Istio"
  type        = string
  default     = "1.9.0"
}

variable "istio_namespace" {
  description = "Namespace of Istio"
  type        = string
  default     = "istio-system"
}