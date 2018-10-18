resource "openstack_networking_router_v2" "router" {
  count            = "${var.openstack_router_create? 1 : 0}"
  name             = "${var.cluster_name}_router"
  admin_state_up   = "true"
  external_gateway = "${var.openstack_external_gateway_id}"
}

resource "openstack_networking_network_v2" "network" {
  count          = "${var.openstack_network_create? 1 : 0}"
  name           = "${var.cluster_name}_network"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet" {
  count      = "${var.openstack_network_subnet_create? 1 : 0}"
  name       = "${var.cluster_name}_subnet"
  network_id = "${element(openstack_networking_network_v2.network.*.id, 1)}"
  cidr       = "${var.openstack_subnet_cidr}"
  subnetpool_id = "${var.openstack_subnet_subnetpool_id}"
  ip_version = 4
}

resource "openstack_networking_router_interface_v2" "interface" {
  count     = "${var.openstack_router_create? 1 : 0}"
  router_id = "${coalesce(var.openstack_router_id, join("", openstack_networking_router_v2.router.*.id))}"
  subnet_id = "${coalesce(var.openstack_subnet_id, join("", openstack_networking_subnet_v2.subnet.*.id))}"
}
