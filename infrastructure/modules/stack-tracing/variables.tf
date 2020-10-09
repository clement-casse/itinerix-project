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

variable "domain_name" {
  description = ""
  type        = string
  default     = "localhost"
}

variable "jaeger_users" {
  description = ""
  type        = string
  default     = <<-EOF
  user:$apr1$vc.rsten$MtYRDGJKMdgQmmO0X53211
  admin:$apr1$UvpJMorq$DGC7ohuDc2gNotSzSEhwK1
  EOF
}
