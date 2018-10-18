variable "cluster_name" {
  type = "string"
}

variable "subnet_cidr" {
  type = "string"
  description = "The subnet cidr for this network. (not kubernetes pods/services)"
}
