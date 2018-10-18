resource "openstack_networking_secgroup_v2" "base" {
  name        = "${var.cluster_name}_base"
  description = "Base kubernetes connectivity"
}

module "default" {
  source      = "rules/default"
  secgroup_id = "${openstack_networking_secgroup_v2.base.id}"
  subnet_cidr = "${var.subnet_cidr}"
}

resource "openstack_networking_secgroup_v2" "k8s" {
  name                 = "${var.cluster_name}_k8s"
  description          = "Ports needed by Kubernetes"
  delete_default_rules = true
}

module "k8s" {
  source       = "rules/k8s"
  secgroup_id  = "${openstack_networking_secgroup_v2.k8s.id}"
  subnet_cidr  = "${var.subnet_cidr}"
}

resource "openstack_networking_secgroup_v2" "k8s_nodes" {
  name                 = "${var.cluster_name}_k8s_nodes"
  description          = "Ports needed by Kubernetes nodes"
  delete_default_rules = true
}

module "k8s_nodes" {
  source       = "rules/k8s_nodes"
  secgroup_id  = "${openstack_networking_secgroup_v2.k8s_nodes.id}"
  subnet_cidr  = "${var.subnet_cidr}"
}

resource "openstack_networking_secgroup_v2" "etcd" {
  name                 = "${var.cluster_name}_etcd"
  description          = "Ports needed by etcd"
  delete_default_rules = true
}

module "etcd" {
  source       = "rules/etcd"
  secgroup_id  = "${openstack_networking_secgroup_v2.etcd.id}"
  subnet_cidr  = "${var.subnet_cidr}"
}
