resource "openstack_networking_secgroup_rule_v2" "etcd" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 2379
  port_range_max    = 2380
  protocol          = "tcp"
  remote_ip_prefix  = "${var.subnet_cidr}"
  security_group_id = "${var.secgroup_id}"
}


# temporarily open ingress from anywhere to let pass the floating Ips
# TODO: use extra variables to configure this dynamically
resource "openstack_networking_secgroup_rule_v2" "etcd_floating" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 2379
  port_range_max    = 2380
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${var.secgroup_id}"
}
