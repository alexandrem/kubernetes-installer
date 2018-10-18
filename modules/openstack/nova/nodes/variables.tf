variable "cluster_name" {
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

variable "openstack_security_group_names" {
  type = "list"
}

variable "openstack_keypair_name" {
  type = "string"
}

variable "openstack_nova_attach_worker_floating" {
  type    = "string"
  default = true

  description = <<EOF
True to attach a floating IP to each worker node.
If your floating IPs are scarce resources or that private Ips are routable in your infrastructure, then
you most likely should set this to false.
EOF
}

variable "openstack_floatingip_pool" {
  type    = "string"
  default = "public"

  description = <<EOF
The openstack nova pool name for floating IPs.
EOF
}
