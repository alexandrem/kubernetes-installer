resource "openstack_networking_router_v2" "net1_router" {
  count            = "${var.openstack_net1_router_create? 1 : 0}"
  name             = "${var.cluster_name}_router"
  admin_state_up   = "true"
  external_gateway = "${var.openstack_net1_external_gateway_id}"
}

resource "openstack_networking_network_v2" "net1_network" {
  count          = "${var.openstack_net1_network_create? 1 : 0}"
  name           = "${var.cluster_name}_dual_net1_network"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "net1_subnet" {
  count      = "${var.openstack_net1_network_subnet_create? 1 : 0}"
  name       = "${var.cluster_name}_subnet"
  network_id = "${element(openstack_networking_network_v2.net1_network.*.id, 1)}"
  cidr       = "${var.openstack_net1_subnet_cidr}"
  subnetpool_id = "${var.openstack_net1_subnet_subnetpool_id}"
  ip_version = 4

  allocation_pools = ["${var.openstack_net1_subnet_allocation_pools}"]
  host_routes = ["${var.openstack_net1_subnet_host_routes}"]
}

resource "openstack_networking_router_interface_v2" "net1_interface" {
  count     = "${var.openstack_net1_router_create? 1 : 0}"
  router_id = "${coalesce(var.openstack_net1_router_id, join("", openstack_networking_router_v2.net1_router.*.id))}"
  subnet_id = "${coalesce(var.openstack_net1_subnet_id, join("", openstack_networking_subnet_v2.net1_subnet.*.id))}"
}
