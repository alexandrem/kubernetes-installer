variable "cluster_name" {
  type = "string"
}

variable "openstack_net1_external_gateway_id" {
  type    = "string"
  default = ""

  description = <<EOF
Neutron network gateway id to connect the first router.
EOF
}

variable "openstack_net2_external_gateway_id" {
  type    = "string"
  default = ""

  description = <<EOF
Neutron network gateway id to connect the second router.
EOF
}

variable "openstack_net1_network_id" {
  type    = "string"
  default = ""

  description = <<EOF
Existing neutron network id to create ports.
By default will create a new one.
EOF
}

variable "openstack_net1_network_name" {
  type    = "string"
  default = ""

  description = <<EOF
Existing neutron network name to create ports.
By default will create a new one.
EOF
}

variable "openstack_net2_network_id" {
  type    = "string"
  default = ""

  description = <<EOF
Existing neutron network id to create ports.
By default will create a new one.
EOF
}

variable "openstack_net2_network_name" {
  type    = "string"
  default = ""

  description = <<EOF
Existing neutron network name to create ports.
By default will create a new one.
EOF
}

variable "openstack_net1_subnet_id" {
  type    = "string"
  default = ""

  description = <<EOF
Existing neutron network subnet id to create ports.
By default will create a new one.
EOF
}

variable "openstack_net1_subnet_name" {
  type    = "string"
  default = ""

  description = <<EOF
Existing neutron network subnet name to create ports.
By default will create a new one.
EOF
}

variable "openstack_net1_subnet_allocation_pools" {
  type = "list"
  default = []
  description = <<EOF
List of hash object to define allocation pools in subnet.
Format:
  {
    start = "<start>"
    end   = "<end>"
  },
EOF
}

variable "openstack_net1_subnet_host_routes" {
  type = "list"
  default = []
  description = <<EOF
List of hash object to inject static routes in subnet.
Format:
  {
    destination_cidr = "<cidr>"
    next_hop         = "<ip>"
  },
EOF
}

variable "openstack_net2_subnet_allocation_pools" {
  type = "list"
  default = []
  description = <<EOF
List of hash object to define allocation pools in subnet.
Format:
  {
    start = "<start>"
    end   = "<end>"
  },
EOF
}

variable "openstack_net2_subnet_host_routes" {
  type = "list"
  default = []
  description = <<EOF
List of hash object to inject static routes in subnet.
Format:
  {
    destination_cidr = "<cidr>"
    next_hop         = "<ip>"
  },
EOF
}

variable "openstack_net2_subnet_id" {
  type    = "string"
  default = ""

  description = <<EOF
Existing neutron network subnet id to create ports.
By default will create a new one.
EOF
}

variable "openstack_net2_subnet_name" {
  type    = "string"
  default = ""

  description = <<EOF
Existing neutron network subnet name to create ports.
By default will create a new one.
EOF
}

variable "openstack_net1_subnet_cidr" {
    type = "string"
    default = ""
}

variable "openstack_net1_subnet_subnetpool_id" {
  type = "string"
  default = ""
}

variable "openstack_net2_subnet_cidr" {
    type = "string"
    default = ""
}

variable "openstack_net2_subnet_subnetpool_id" {
  type = "string"
  default = ""
}

variable "openstack_net1_router_id" {
  type    = "string"
  default = ""

  description = <<EOF
Existing neutron router id to create ports.
By default will create a new one.
EOF
}

variable "openstack_net1_router_name" {
  type    = "string"
  default = ""

  description = <<EOF
Existing neutron network name to create ports.
By default will create a new one.
EOF
}

variable "openstack_net2_router_id" {
  type    = "string"
  default = ""

  description = <<EOF
Existing neutron router id to create ports.
By default will create a new one.
EOF
}

variable "openstack_net2_router_name" {
  type    = "string"
  default = ""

  description = <<EOF
Existing neutron network name to create ports.
By default will create a new one.
EOF
}

variable "openstack_net1_router_create" {
  description = "Whether to create the router for kubernetes nodes network."
  default     = true
}

variable "openstack_net1_network_create" {
  description = "Whether to create the network for kubernetes nodes."
  default     = true
}

variable "openstack_net1_network_subnet_create" {
  description = "Whether to create the subnet for kubernetes nodes network."
  default     = true
}

variable "openstack_net2_router_create" {
  description = "Whether to create the router for kubernetes nodes network."
  default     = true
}

variable "openstack_net2_network_create" {
  description = "Whether to create the network for kubernetes nodes."
  default     = true
}

variable "openstack_net2_network_subnet_create" {
  description = "Whether to create the subnet for kubernetes nodes network."
  default     = true
}
