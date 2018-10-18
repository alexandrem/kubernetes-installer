output "floatingip_addresses" {
  value = [
    "${openstack_compute_floatingip_v2.node.*.address}",
  ]
}

output "compute_instance_ids" {
  value = [
    "${openstack_compute_instance_v2.node.*.id}",
  ]
}
