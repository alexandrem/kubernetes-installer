output "floatingip_addresses" {
  value = [
    "${openstack_networking_floatingip_v2.node.*.address}",
  ]
}

output "compute_instance_ids" {
  value = ["${concat(
    openstack_compute_instance_v2.single_port_node.*.id,
    openstack_compute_instance_v2.dual_ports_node.*.id,
  )}"]
}

output "single_port_ids" {
  value = [
    "${openstack_networking_port_v2.single_port.*.id}",
  ]
}

output "dual_ports_ids" {
  value = [
    "${openstack_networking_port_v2.dual_ports.*.id}",
  ]
}

output "fixed_ips" {
  value = ["${concat(
    flatten(openstack_networking_port_v2.single_port.*.all_fixed_ips),
    flatten(openstack_networking_port_v2.dual_ports.*.all_fixed_ips),
  )}"
  ]
}
