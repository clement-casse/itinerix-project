variable "gke_project" {
  description = "The project in which to hold the components"
  type        = string
}
variable "gke_region" {
  description = "The region in which to create the VPC network"
  type        = string
}

variable "gke_cluster_name" {
  description = "The name to give the new Kubernetes cluster"
  type        = string
}
variable "gke_zone_pool_1" {
  description = "The zone in which to create the first Kubernetes cluster. Must match the region"
  type        = string
}
variable "gke_zone_pool_2" {
  description = "The zone in which to create the second Kubernetes cluster. Must match the region"
  type        = string
}

variable "acme_email" {
  description = "Email for user registration in LetsEncrypt"
  type        = string
}

variable "acme_domain" {
  description = "Domain name of the root zone"
  type        = string
}

variable "dashboard_users" {
  description = "htpasswd entries to restruct access to ServiceMesh Dashbaord"
  type        = string
}