resource "openstack_compute_servergroup_v2" "group" {
  name     = "${var.cluster_name}-${var.node_role}-group"
  policies = ["anti-affinity"]
}

resource "openstack_compute_instance_v2" "node" {
  count = "${var.node_count}"

  name = "${var.cluster_name}-${format("%s-%02d", var.node_role, count.index+1)}"

  image_name = "${var.openstack_image_name}"
  image_id   = "${var.openstack_image_id}"

  flavor_name = "${var.openstack_flavor_name}"
  flavor_id   = "${var.openstack_flavor_id}"

  metadata {
    role = "${var.node_role}"
  }

  scheduler_hints {
    group = "${openstack_compute_servergroup_v2.group.id}"
  }

  key_pair = "${var.openstack_keypair_name}"

  security_groups = ["${var.openstack_security_group_names}"]

  config_drive = false

  lifecycle {
    ignore_changes = ["name", "user_data", "image_name", "image_id"]

    prevent_destroy = false
  }
}
