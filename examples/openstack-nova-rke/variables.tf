variable "cluster_name" {
  type = "string"
}

variable "etcd_count" {
  type    = "string"
  default = "0"
}

variable "master_count" {
  type    = "string"
  default = "0"
}

variable "worker_count" {
  type    = "string"
  default = "0"
}

variable "ssh_user" {
  type        = "string"
  default     = "root"
  description = "SSH user for connection of provisioned nodes"
}

variable "openstack_master_flavor_name" {
  type    = "string"
  default = ""

  description = <<EOF
The flavor name for master instances as given in `openstack flavor list`. Specifies the size (CPU/Memory/Drive) of the VM.

Note: Set either openstack_master_flavor_name or openstack_master_flavor_id.
EOF
}

variable "openstack_worker_flavor_name" {
  type    = "string"
  default = ""

  description = <<EOF
The flavor name for worker instances as given in `openstack flavor list`. Specifies the size (CPU/Memory/Drive) of the VM.

Note: Set either openstack_worker_flavor_name or openstack_worker_flavor_id.
EOF
}

variable "openstack_etcd_flavor_name" {
  type    = "string"
  default = ""

  description = <<EOF
(optional) The flavor name for etcd instances as given in `openstack flavor list`. Specifies the size (CPU/Memory/Drive) of the VM.

Note: Set either openstack_etcd_flavor_name or openstack_etcd_flavor_id.
Note: This value is ignored for self-hosted etcd.
EOF
}

variable "openstack_master_flavor_id" {
  type    = "string"
  default = ""

  description = <<EOF
The flavor id for master instances as given in `openstack flavor list`. Specifies the size (CPU/Memory/Drive) of the VM.

Note: Set either openstack_master_flavor_name or openstack_master_flavor_id.
EOF
}

variable "openstack_worker_flavor_id" {
  type    = "string"
  default = ""

  description = <<EOF
The flavor id for worker instances as given in `openstack flavor list`. Specifies the size (CPU/Memory/Drive) of the VM.

Note: Set either openstack_worker_flavor_name or openstack_worker_flavor_id.
EOF
}

variable "openstack_etcd_flavor_id" {
  type    = "string"
  default = ""

  description = <<EOF
(optional) The flavor id for etcd instances as given in `openstack flavor list`. Specifies the size (CPU/Memory/Drive) of the VM.

Note: Set either openstack_etcd_flavor_name or openstack_etcd_flavor_id.
Note: This value is ignored for self-hosted etcd.
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
The name name of the floating IP pool
as given in `openstack floating ip list`.
This pool will be used to assign floating IPs to worker and master nodes.
EOF
}

variable "dns_nameservers_custom" {
  default = true

  description = <<EOF
To overwrite default /etc/resolv.conf of node with custom list of nameservers.
Otherwise will use default injected in VM.
EOF
}

variable "dns_nameservers" {
  type    = "list"
  default = ["8.8.8.8", "8.8.4.4"]

  description = <<EOF
The nameservers used by the nodes and the generated OpenStack subnet resource.

Example: `["8.8.8.8", "8.8.4.4"]`
EOF
}

variable "rke_install_script_url" {
  type    = "string"
  default = "https://releases.rancher.com/install-docker/17.03.sh"
}

variable "openstack_compute_floatingip_pool" {
  type    = "string"
  default = "nova"

  description = <<EOF
The openstack nova pool name for floating IPs.
EOF
}

variable "cloud_provider" {
  type    = "string"
  default = "openstack"
}

variable "openstack_auth_url" {
  type = "string"
}

variable "openstack_username" {
  type = "string"
}

variable "openstack_password" {
  type = "string"
}

variable "openstack_region" {
  type = "string"
}

variable "openstack_tenant_id" {
  type    = "string"
  default = ""
}

variable "openstack_tenant_name" {
  type    = "string"
  default = ""
}

variable "openstack_domain_name" {
  type    = "string"
  default = ""
}

variable "openstack_domain_id" {
  type    = "string"
  default = ""
}

# Below is not implemented yet
variable "docker_storage_block_device_mount" {
  description = "True to mount a block device to use for docker storage path"
  default     = false
}

variable "docker_storage_block_device_name" {
  description = "Block device name (/dev/<xxx>) to use for docker storage"
  default     = "/dev/vdb"
}

variable "docker_storage_block_device_format" {
  description = "Automatically format a block device that will serve for docker storage. Set to false if block device is a volume already formated."
  default     = true
}

variable "docker_storage_block_device_format_filesystem" {
  description = "Filesystem to use for the block device format operation."
  default     = "ext4"
}
