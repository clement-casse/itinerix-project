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

variable "domain_name" {
  description = ""
  type        = string
  default     = "localhost"
}

variable "linkerd_version" {
  description = "Version Number of Linkerd"
  type        = string
  default     = "2.10.1"
}

variable "linkerd_namespace" {
  description = "Namespace to install Linkerd on"
  type        = string
  default     = "linkerd"
}

variable "dashboard_users" {
  description = ""
  type        = string
  default     = <<-EOF
  user:$apr1$vc.rsten$MtYRDGJKMdgQmmO0X53211
  admin:$apr1$UvpJMorq$DGC7ohuDc2gNotSzSEhwK1
  EOF
}

variable "tracing_namespace" {
  description = "Namespace in which Jaeger UI is installed"
  type        = string
  default     = "jaeger"
}

variable "polynote_namespace" {
  description = "Namespace in which polynote is installed"
  type        = string
  default     = "data"
}
