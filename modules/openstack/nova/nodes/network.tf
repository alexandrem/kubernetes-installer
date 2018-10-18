resource "openstack_compute_floatingip_v2" "node" {
  count = "${var.openstack_nova_attach_worker_floating? var.node_count : 0}"
  pool  = "${var.openstack_floatingip_pool}"

  lifecycle {
    prevent_destroy = false
  }
}

resource "openstack_compute_floatingip_associate_v2" "node" {
  count = "${var.openstack_nova_attach_worker_floating? var.node_count : 0}"

  floating_ip = "${openstack_compute_floatingip_v2.node.*.address[count.index]}"
  instance_id = "${openstack_compute_instance_v2.node.*.id[count.index]}"
}
