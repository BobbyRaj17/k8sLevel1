#####################################################################
# Variables
#####################################################################
variable "project" {
  type = "string"
  default = "bobtestproject"
}

variable "region" {
  type = "string"
  default = "us-central1"
}

variable "zone" {
  type = "string"
  default = "us-central1-a"
}

variable "username" {
  default = "admin"
}
variable "password" {
  default = "admin"
}
variable "cluster_machine_type" {
  type = "string"
  description = "The machine type for Kubernetes cluster nodes."
  default = "n1-standard-1"
}