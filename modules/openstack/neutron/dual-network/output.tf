output "net1_router_id" {
  value = "${length(openstack_networking_router_v2.net1_router.*.id) >0? element(openstack_networking_router_v2.net1_router.*.id, 1) : ""}"
}

output "net1_network_id" {
  value = "${length(openstack_networking_network_v2.net1_network.*.id) > 0? element(openstack_networking_network_v2.net1_network.*.id, 1) : ""}"
}

output "net1_subnet_id" {
  value = "${length(openstack_networking_subnet_v2.net1_subnet.*.id) > 0? element(openstack_networking_subnet_v2.net1_subnet.*.id, 1) : ""}"
}

output "net2_router_id" {
  value = "${length(openstack_networking_router_v2.net2_router.*.id) >0? element(openstack_networking_router_v2.net2_router.*.id, 1) : ""}"
}

output "net2_network_id" {
  value = "${length(openstack_networking_network_v2.net2_network.*.id) > 0? element(openstack_networking_network_v2.net2_network.*.id, 1) : ""}"
}

output "net2_subnet_id" {
  value = "${length(openstack_networking_subnet_v2.net2_subnet.*.id) > 0? element(openstack_networking_subnet_v2.net2_subnet.*.id, 1) : ""}"
}