variable "project" {
  description = "The project in which to hold the components"
  type        = string
}

variable "region" {
  description = "The region in which to create the VPC network"
  type        = string
}

variable "zone_pool_1" {
  description = "The zone in which to create the first Kubernetes cluster. Must match the region"
  type        = string
}

variable "zone_pool_2" {
  description = "The zone in which to create the second Kubernetes cluster. Must match the region"
  type        = string
}


// Optional values that can be overridden or appended to if desired.
variable "cluster_name" {
  description = "The name to give the new Kubernetes cluster."
  type        = string
  default     = "private-cluster"
}
