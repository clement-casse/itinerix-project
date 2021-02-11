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

variable "acme_email" {
  description = ""
  type        = string
  default     = ""
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

variable "domain_name" {
  description = ""
  type        = string
  default     = "localhost"
}

variable "certmanager_version" {
  description = "Version Number of cert-manager"
  type        = string
  default     = "v1.1.0"
}

variable "certificates_target_ns" {
  description = "K8S Namespace in which certificates are going to be installed"
  type        = string
  default     = "default"
}

variable "certificates_to_create" {
  description = "list of domains to create a certificate"
  type        = list(string)
  default     = []
}