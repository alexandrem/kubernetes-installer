resource "openstack_compute_servergroup_v2" "group" {
  name     = "${var.prefix}-${var.node_role}-group"
  policies = ["anti-affinity"]
}

resource "openstack_networking_port_v2" "single_port" {
  count              = "${var.openstack_network_count == 1? var.node_count : 0}"
  name               = "${var.prefix}_port_${count.index}"
  network_id         = "${element(var.openstack_network_ids, count.index)}"

  security_group_ids = ["${var.openstack_security_group_ids}"]
  admin_state_up     = "true"

  fixed_ip {
    # only supports 1 subnet per network
    subnet_id = "${element(var.openstack_network_subnet_ids, count.index)}"
  }
}

resource "openstack_networking_port_v2" "dual_ports" {
  count              = "${var.openstack_network_count == 2? (2*var.node_count) : 0}"
  name               = "${var.prefix}_port_${count.index}"
  network_id         = "${element(var.openstack_network_ids, count.index%2)}"

  security_group_ids = ["${var.openstack_security_group_ids}"]
  admin_state_up     = "true"

  fixed_ip {
    # only supports 1 subnet per network
    subnet_id = "${element(var.openstack_network_subnet_ids, count.index%2)}"
  }
}

resource "openstack_compute_instance_v2" "single_port_node" {
  count = "${var.openstack_network_count == 1? var.node_count : 0}"

  name = "${var.prefix}-${format("%s-%02d", var.node_role, count.index+1)}"

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


  # security_groups = ["${var.openstack_security_group_names}"]

  network = [
    {
      port = "${element(openstack_networking_port_v2.single_port.*.id, count.index)}",
    },
  ]

  config_drive = false

  user_data = "${var.openstack_user_data}"

  lifecycle {
    ignore_changes = ["name", "user_data", "image_name", "image_id"]

    prevent_destroy = false
  }
}

resource "openstack_compute_instance_v2" "dual_ports_node" {
  count = "${var.openstack_network_count == 2? var.node_count : 0}"

  name = "${var.prefix}-${format("%s-%02d", var.node_role, count.index+1)}"

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


  # security_groups = ["${var.openstack_security_group_names}"]

  network = [
    {
      port = "${element(openstack_networking_port_v2.dual_ports.*.id, count.index*2)}",
    },
    {
      port = "${element(openstack_networking_port_v2.dual_ports.*.id, count.index*2 + 1)}",
    },
  ]

  config_drive = false

  user_data = "${var.openstack_user_data}"

  lifecycle {
    # ignore_changes = ["name", "user_data", "image_name", "image_id"]
    ignore_changes = ["name", "image_name", "image_id"]

    prevent_destroy = false
  }
}


resource "openstack_networking_floatingip_v2" "node" {
  count = "${var.openstack_associate_floating_ip? var.node_count : 0}"
  pool  = "${var.openstack_floatingip_pool}"
}

resource "openstack_compute_floatingip_associate_v2" "single_port_node" {
  count = "${var.openstack_network_count == 1 && var.openstack_associate_floating_ip ? var.node_count : 0}"

  floating_ip = "${openstack_networking_floatingip_v2.node.*.address[count.index]}"
  instance_id = "${openstack_compute_instance_v2.single_port_node.*.id[count.index]}"
}

resource "openstack_compute_floatingip_associate_v2" "dual_ports_node" {
  count = "${var.openstack_network_count == 2 && var.openstack_associate_floating_ip ? var.node_count : 0}"

  floating_ip = "${openstack_networking_floatingip_v2.node.*.address[count.index]}"
  instance_id = "${openstack_compute_instance_v2.dual_ports_node.*.id[count.index]}"
}
