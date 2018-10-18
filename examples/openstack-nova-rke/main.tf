terraform {
  required_version = ">= 0.11.0"
}

module "secgroups" {
  source       = "../../modules/openstack/nova/secgroups"
  cluster_name = "${var.cluster_name}"
}

module "secrets" {
  source       = "../../modules/openstack/secrets"
  cluster_name = "${var.cluster_name}"
}

module "master_nodes" {
  source = "../../modules/openstack/nova/nodes"

  cluster_name                   = "${var.cluster_name}"
  node_count                     = "${var.master_count}"
  node_role                      = "master"
  openstack_flavor_name          = "${var.openstack_master_flavor_name}"
  openstack_flavor_id            = "${var.openstack_master_flavor_id}"
  openstack_image_name           = "${var.openstack_image_name}"
  openstack_image_id             = "${var.openstack_image_id}"
  openstack_security_group_names = ["${element(module.secgroups.secgroup_master_names, 1)}"]
  openstack_keypair_name         = "${module.secrets.keypair_name}"
  openstack_floatingip_pool      = "${var.openstack_floatingip_pool}"
}

module "etcd_nodes" {
  source = "../../modules/openstack/nova/nodes"

  cluster_name                   = "${var.cluster_name}"
  node_count                     = "${var.etcd_count}"
  node_role                      = "etcd"
  openstack_flavor_name          = "${var.openstack_etcd_flavor_name}"
  openstack_flavor_id            = "${var.openstack_etcd_flavor_id}"
  openstack_image_name           = "${var.openstack_image_name}"
  openstack_image_id             = "${var.openstack_image_id}"
  openstack_security_group_names = ["${element(module.secgroups.secgroup_master_names, 1)}"]
  openstack_keypair_name         = "${module.secrets.keypair_name}"
  openstack_floatingip_pool      = "${var.openstack_floatingip_pool}"
}

module "worker_nodes" {
  source = "../../modules/openstack/nova/nodes"

  cluster_name                   = "${var.cluster_name}"
  node_count                     = "${var.worker_count}"
  node_role                      = "worker"
  openstack_flavor_name          = "${var.openstack_worker_flavor_name}"
  openstack_flavor_id            = "${var.openstack_worker_flavor_id}"
  openstack_image_name           = "${var.openstack_image_name}"
  openstack_image_id             = "${var.openstack_image_id}"
  openstack_security_group_names = ["${element(module.secgroups.secgroup_worker_names, 1)}"]
  openstack_keypair_name         = "${module.secrets.keypair_name}"
  openstack_floatingip_pool      = "${var.openstack_floatingip_pool}"
}

data "null_data_source" "master_nodes_data" {
  count = "${var.master_count}"

  inputs = {
    address      = "${element(module.master_nodes.floatingip_addresses, count.index)}"
    user         = "${var.ssh_user}"
    role         = "controlplane"
    ssh_key_path = "${path.module}/generated/id_rsa_core"
    labels       = "node-role.kubernetes.io/master="
  }
}

data "null_data_source" "etcd_nodes_data" {
  count = "${var.etcd_count}"

  inputs = {
    address      = "${element(module.etcd_nodes.floatingip_addresses, count.index)}"
    user         = "${var.ssh_user}"
    role         = "etcd"
    ssh_key_path = "${path.module}/generated/id_rsa_core"
    labels       = "node-role.kubernetes.io/master="
  }
}

data "null_data_source" "worker_nodes_data" {
  count = "${var.worker_count}"

  inputs = {
    address      = "${element(module.worker_nodes.floatingip_addresses, count.index)}"
    user         = "${var.ssh_user}"
    role         = "worker"
    ssh_key_path = "${path.module}/generated/id_rsa_core"
    labels       = "node-role.kubernetes.io/node="
  }
}

locals {
  rke_node_objects = "${concat(
    data.null_data_source.master_nodes_data.*.outputs,
    data.null_data_source.etcd_nodes_data.*.outputs,
    data.null_data_source.worker_nodes_data.*.outputs
  )}"

  rke_cloud_config = <<EOF
cloud_config:
    auth-url: "${var.openstack_auth_url}"
    username: "${var.openstack_username}"
    password: "${var.openstack_password}"
    region: "${var.openstack_region}"
    tenant-id: "${var.openstack_tenant_id}"
    tenant-name: "${var.openstack_tenant_name}"
    domain-id: "${var.openstack_domain_id}"
    domain-name: "${var.openstack_domain_name}"
EOF
}

module "rke_provision" {
  source = "../../modules/kubernetes-installer/modules/kubernetes/rke"

  refresh_trigger = {
    masters = "${join(",", module.master_nodes.compute_instance_ids)}"
    etcd    = "${join(",", module.etcd_nodes.compute_instance_ids)}"
    workers = "${join(",", module.worker_nodes.compute_instance_ids)}"
  }

  master_node_objects = "${data.null_data_source.master_nodes_data.*.outputs}"
  etcd_node_objects   = "${data.null_data_source.etcd_nodes_data.*.outputs}"
  worker_node_objects = "${data.null_data_source.worker_nodes_data.*.outputs}"

  cluster_name          = "${var.cluster_name}"
  cluster_service_cidr  = "${var.cluster_service_cidr}"
  cluster_pod_cidr      = "${var.cluster_pod_cidr}"
  cluster_dns_server    = "${var.cluster_dns_server}"
  ignore_docker_version = true

  cloud_provider        = "${var.cloud_provider}"
  openstack_auth_url    = "${var.openstack_auth_url}"
  openstack_username    = "${var.openstack_username}"
  openstack_password    = "${var.openstack_password}"
  openstack_region      = "${var.openstack_region}"
  openstack_tenant_id   = "${var.openstack_tenant_id}"
  openstack_tenant_name = "${var.openstack_tenant_name}"
  openstack_domain_id   = "${var.openstack_domain_id}"
  openstack_domain_name = "${var.openstack_domain_name}"

  http_proxy  = "${var.http_proxy}"
  https_proxy = "${var.https_proxy}"

  api_extra_args = {
    enable-admission-plugins = "ServiceAccount,NamespaceLifecycle,LimitRanger,PersistentVolumeLabel,DefaultStorageClass,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,ResourceQuota,DefaultTolerationSeconds"
  }
}
