resource "openstack_networking_secgroup_rule_v2" "ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 22
  port_range_max    = 22
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${var.secgroup_id}"
}

resource "openstack_networking_secgroup_rule_v2" "docker" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 2376
  port_range_max    = 2376
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${var.secgroup_id}"
}
resource "openstack_networking_secgroup_rule_v2" "icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${var.secgroup_id}"
}

resource "openstack_networking_secgroup_rule_v2" "http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 80
  port_range_max    = 80
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${var.secgroup_id}"
}

resource "openstack_networking_secgroup_rule_v2" "http_8080" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 8080
  port_range_max    = 8080
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${var.secgroup_id}"
}

resource "openstack_networking_secgroup_rule_v2" "https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 443
  port_range_max    = 443
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${var.secgroup_id}"
}

resource "openstack_networking_secgroup_rule_v2" "cAdvisor" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 4194
  port_range_max    = 4194
  protocol          = "tcp"
  remote_ip_prefix  = "${var.subnet_cidr}"
  security_group_id = "${var.secgroup_id}"
}

resource "openstack_networking_secgroup_rule_v2" "vxlan" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 4789
  port_range_max    = 4789
  protocol          = "udp"
  remote_ip_prefix  = "${var.subnet_cidr}"
  security_group_id = "${var.secgroup_id}"
}

resource "openstack_networking_secgroup_rule_v2" "flannel" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 8472
  port_range_max    = 8472
  protocol          = "udp"
  remote_ip_prefix  = "${var.subnet_cidr}"
  security_group_id = "${var.secgroup_id}"
}

# just in case this is calico, we must open all ports
resource "openstack_networking_secgroup_rule_v2" "all-inter-tcp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 1
  port_range_max    = 65535
  protocol          = "tcp"
  remote_ip_prefix  = "${var.subnet_cidr}"
  security_group_id = "${var.secgroup_id}"
}

resource "openstack_networking_secgroup_rule_v2" "all-inter-udp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 1
  port_range_max    = 65535
  protocol          = "udp"
  remote_ip_prefix  = "${var.subnet_cidr}"
  security_group_id = "${var.secgroup_id}"
}
