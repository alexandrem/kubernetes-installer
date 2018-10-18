data template_file "ext_etcd" {
  template = <<EOF
path: /
external_urls:
  - ${indent(2, join("\n- ", split(",", var.external_etcd_urls)))}
ca_cert: |-
  ${indent(2, var.etcd_ca)}
cert: |-
  ${indent(2, var.etcd_cert)}
key: |-
  ${indent(2, var.etcd_key)}
EOF
}

data template_file "rke" {
  template = "${file("${path.module}/templates/rke-minimal.yml")}"

  vars {
    nodes                  = "${lookup(data.external.rke.result, "rke_template_nodes")}"
    cluster_name           = "${var.cluster_name}"
    kubernetes_version     = "${var.kubernetes_version == ""? "" : format("kubernetes_version: %s", var.kubernetes_version)}"
    cluster_pod_cidr       = "${var.cluster_pod_cidr}"
    cluster_dns_server     = "${var.cluster_dns_server}"
    cluster_service_cidr   = "${var.cluster_service_cidr}"
    cloud_provider         = "${var.cloud_provider}"
    openstack_cloud_config = "${var.cloud_provider == "openstack"? indent(2, local.openstack_cloud_config) : ""}"
    service_etcd           = "${indent(4, data.template_file.ext_etcd.rendered)}"
    ignore_docker_version  = "${var.ignore_docker_version? "true" : "false"}"
    api_extra_args         = "${indent(6, lookup(data.external.api_extra_args.result, "yaml"))}"
    controller_extra_args  = "${indent(6, lookup(data.external.controller_extra_args.result, "yaml"))}"
    kubelet_extra_args     = "${indent(6, lookup(data.external.kubelet_extra_args.result, "yaml"))}"
    network_plugin         = "${var.network_plugin}"
    network_options        = "${indent(4, lookup(data.external.network_options.result, "yaml"))}"
  }
}

resource "local_file" "rke" {
  content  = "${data.template_file.rke.rendered}"
  filename = "generated/cluster.yml"
}

# could do some pre-provisioning stuffs on coreos images here
resource "null_resource" "pre_provision" {
  count = "${length(local.rke_node_objects)}"

  triggers = "${var.refresh_trigger}"

  connection {
    host        = "${lookup(local.rke_node_objects[count.index], "address")}"
    private_key = "${file(lookup(local.rke_node_objects[count.index], "ssh_key_path"))}"
    user        = "${lookup(local.rke_node_objects[count.index], "user")}"
  }

  provisioner "remote-exec" {
    inline = [
      # the "or true" is necessary for coreos where the curl script will return non zero
      # because docker already exists.
      # Not doing so will break terraform dependencies on pre_provision down the line
      "curl ${var.rke_install_script_url} | sh || true",
    ]
  }
}

resource "null_resource" "rke" {
  triggers = "${merge(
    var.refresh_trigger,
    map(
      "template", "${data.template_file.rke.rendered}",
    ),
  )}"

  provisioner "local-exec" {
    command = "cd generated && rke up"
  }

  depends_on = [
    "null_resource.pre_provision",
  ]
}
