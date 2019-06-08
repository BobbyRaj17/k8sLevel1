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


#####################################################################
# Modules
#####################################################################
module "gke" {
  source   = "./gke"
  project  = "${var.project}"
  region   = "${var.region}"
}
