resource "openstack_networking_secgroup_rule_v2" "kube_api" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 6443
  port_range_max    = 6443
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${var.secgroup_id}"
}

resource "openstack_networking_secgroup_rule_v2" "kubernetes-daemons" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 10250
  port_range_max    = 10256
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${var.secgroup_id}"
}

# we also open node ports on master nodes
resource "openstack_networking_secgroup_rule_v2" "node_ports" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 30000
  port_range_max    = 32767
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${var.secgroup_id}"
}
