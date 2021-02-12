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

variable "jaeger_host" {
  description = ""
  type        = string
  default     = "localhost"
}

variable "jaeger_pathprefix" {
  description = ""
  type        = string
  default     = "/jaeger"
}

variable "jaeger_users" {
  description = ""
  type        = string
  default     = <<-EOF
  user:$apr1$vc.rsten$MtYRDGJKMdgQmmO0X53211
  admin:$apr1$UvpJMorq$DGC7ohuDc2gNotSzSEhwK1
  EOF
}

variable "jaeger_install_ns" {
  description = "K8S namespace on which Jaeger will be installed, Must Exist beforehand"
  type        = string
  default     = "jaeger"
}
