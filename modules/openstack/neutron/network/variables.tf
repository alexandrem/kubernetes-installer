variable "cluster_name" {
  type = "string"
}

variable "openstack_external_gateway_id" {
  type    = "string"
  default = ""

  description = <<EOF
Neutron network gateway id to connect the router.
EOF
}

variable "openstack_network_id" {
  type    = "string"
  default = ""

  description = <<EOF
Existing neutron network id to create ports.
By default will create a new one.
EOF
}

variable "openstack_network_name" {
  type    = "string"
  default = ""

  description = <<EOF
Existing neutron network name to create ports.
By default will create a new one.
EOF
}

variable "openstack_subnet_id" {
  type    = "string"
  default = ""

  description = <<EOF
Existing neutron network subnet id to create ports.
By default will create a new one.
EOF
}

variable "openstack_subnet_name" {
  type    = "string"
  default = ""

  description = <<EOF
Existing neutron network subnet name to create ports.
By default will create a new one.
EOF
}

variable "openstack_subnet_cidr" {
    type = "string"
    default = ""
}

variable "openstack_subnet_subnetpool_id" {
  type = "string"
  default = ""
}

variable "openstack_router_id" {
  type    = "string"
  default = ""

  description = <<EOF
Existing neutron router id to create ports.
By default will create a new one.
EOF
}

variable "openstack_router_name" {
  type    = "string"
  default = ""

  description = <<EOF
Existing neutron network name to create ports.
By default will create a new one.
EOF
}

variable "openstack_router_create" {
  description = "Whether to create the router for kubernetes nodes network."
  default     = true
}

variable "openstack_network_create" {
  description = "Whether to create the network for kubernetes nodes."
  default     = true
}

variable "openstack_network_subnet_create" {
  description = "Whether to create the subnet for kubernetes nodes network."
  default     = true
}
