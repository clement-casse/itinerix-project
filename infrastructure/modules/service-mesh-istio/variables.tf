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
