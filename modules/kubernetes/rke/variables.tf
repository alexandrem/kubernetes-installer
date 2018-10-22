variable "master_node_objects" {
  type    = "list"
  default = []
}

variable "etcd_node_objects" {
  type    = "list"
  default = []
}

variable "worker_node_objects" {
  type    = "list"
  default = []
}

variable "master_count" {
  type    = "string"
  default = 0
}

variable "etcd_count" {
  type    = "string"
  default = 0
}

variable "worker_count" {
  type    = "string"
  default = 0
}

variable "refresh_trigger" {
  type        = "map"
  description = "Map of valuesfor etcd join resource triggers. Same format as null_resource triggers."
}

variable "cluster_name" {
  type = "string"
}

variable "kubernetes_version" {
  type        = "string"
  default     = ""
  description = "The Rancher release version to use. This is dependent on the RKE binary used on the local system. Empty means default."
}

variable "cluster_service_cidr" {
  type    = "string"
  default = "192.168.0.0/17"
}

variable "cluster_pod_cidr" {
  type    = "string"
  default = "192.168.128.0/17"
}

variable "cluster_dns_server" {
  type    = "string"
  default = "192.168.0.10"
}

variable "ignore_docker_version" {
  type    = "string"
  default = false
}

variable "rke_install_script_url" {
  type    = "string"
  default = "https://releases.rancher.com/install-docker/17.03.sh"
}

variable "external_etcd_urls" {
  type        = "string"
  default     = ""
  description = "If using external etcd cert, then specify the full client endpoint urls connection string."
}

variable "etcd_ca" {
  type        = "string"
  description = "CA cert content. If using external etcd cluster, then you must pass this."
}

variable "etcd_cert" {
  type        = "string"
  description = "Client cert content. If using external etcd cluster, then you must pass this."
}

variable "etcd_key" {
  type        = "string"
  description = "Client cert key content. If using external etcd cluster, then you must pass this."
}

variable "cloud_provider" {
  type = "string"
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

variable "api_extra_args" {
  type    = "map"
  default = {}
}

variable "controller_extra_args" {
  type    = "map"
  default = {}
}

variable "kubelet_extra_args" {
  type    = "map"
  default = {}
}

variable "network_plugin" {
  type    = "string"
  default = "canal"
}

variable "network_options" {
  type    = "map"
  default = {}
}

variable "http_proxy" {
  type    = "string"
  default = ""
}

variable "https_proxy" {
  type    = "string"
  default = ""
}

variable "depends_on" {
  type    = "string"
  default = ""
}

variable "force_provision" {
  type    = "string"
  default = false
}
