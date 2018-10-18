variable "prefix" {
  type = "string"
}

variable "node_role" {
  type = "string"
}

variable "node_count" {
  type    = "string"
  default = "0"
}

variable "openstack_flavor_name" {
  type    = "string"
  default = ""

  description = <<EOF
The flavor name for worker instances as given in `openstack flavor list`. Specifies the size (CPU/Memory/Drive) of the VM.

Note: Set either openstack_worker_flavor_name or openstack_worker_flavor_id.
EOF
}

variable "openstack_flavor_id" {
  type    = "string"
  default = ""

  description = <<EOF
The flavor id for worker instances as given in `openstack flavor list`. Specifies the size (CPU/Memory/Drive) of the VM.

Note: Set either openstack_worker_flavor_name or openstack_worker_flavor_id.
EOF
}

variable "openstack_image_name" {
  type    = "string"
  default = ""

  description = <<EOF
The image ID as given in `openstack image list`. Specifies the OS image of the VM.

Note: Set either openstack_image_name or openstack_image_id.
EOF
}

variable "openstack_image_id" {
  type    = "string"
  default = ""

  description = <<EOF
The image ID as given in `openstack image list`. Specifies the OS image of the VM.

Note: Set either openstack_image_name or openstack_image_id.
EOF
}

variable "openstack_security_group_ids" {
  type = "list"
  default = []
}

variable "openstack_keypair_name" {
  type = "string"
}

variable "openstack_floatingip_pool" {
  type    = "string"
  default = "public"

  description = <<EOF
The openstack nova pool name for floating IPs.
EOF
}

variable "openstack_network_count" {
  type = "string"
  default = 1
}

variable "openstack_network_ids" {
  type = "list"
}

variable "openstack_network_subnet_ids" {
  type = "list"
  default = []
}

variable "openstack_network_port_ids" {
  type = "list"
  default = []
  description = "List of port ids to connect nodes to"
}

variable "openstack_user_data" {
  type = "string"
  default = ""
}

variable "openstack_associate_floating_ip" {
  default = true
}
