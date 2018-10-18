locals {
  rke_node_objects = "${concat(
    var.master_node_objects,
    var.etcd_node_objects,
    var.worker_node_objects,
  )}"

  default_api_extra_args = {
    enable-admission-plugins = "ServiceAccount,NamespaceLifecycle,LimitRanger,PersistentVolumeLabel,DefaultStorageClass,ResourceQuota,DefaultTolerationSeconds"
  }

  default_controller_extra_args = {}
  default_kubelet_extra_args    = {}
  default_network_options       = {}

  api_extra_args = "${merge(
    local.default_api_extra_args,
    var.api_extra_args,
  )}"

  controller_extra_args = "${merge(
    local.default_controller_extra_args,
    var.controller_extra_args,
  )}"

  kubelet_extra_args = "${merge(
    local.default_kubelet_extra_args,
    var.kubelet_extra_args,
  )}"

  network_options = "${merge(
    local.default_network_options,
    var.network_options,
  )}"

  openstack_cloud_config = <<EOF
openstackCloudProvider:
  global:
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

# this external script is required to tranform the generated nodes map into a yaml
# that will be injected into RKE template
data "external" "rke" {
  program = ["python3", "${path.module}/scripts/generate-nodes.py"]

  query = {
    nodes = "${jsonencode(local.rke_node_objects)}"
  }
}

data "external" "api_extra_args" {
  program = ["python3", "${path.module}/scripts/toyaml.py"]

  query = {
    data = "${jsonencode(local.api_extra_args)}"
  }
}

data "external" "controller_extra_args" {
  program = ["python3", "${path.module}/scripts/toyaml.py"]

  query = {
    data = "${jsonencode(local.controller_extra_args)}"
  }
}

data "external" "kubelet_extra_args" {
  program = ["python3", "${path.module}/scripts/toyaml.py"]

  query = {
    data = "${jsonencode(local.kubelet_extra_args)}"
  }
}

data "external" "network_options" {
  program = ["python3", "${path.module}/scripts/toyaml.py"]

  query = {
    data = "${jsonencode(local.network_options)}"
  }
}
