variable "project" {
  description = "The project in which to hold the components"
  type        = string
}

variable "region" {
  description = "The region of the google project"
  type        = string
}

variable "load_balancer_ip" {
  description = "IP address to be bound to the domains"
  type        = string
}
