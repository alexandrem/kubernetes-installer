data "template_file" "docker_mount" {
  template = "${file("${path.module}/resources/services/var-lib-docker.mount")}"

  vars {
    device_path = "${var.storage_block_device_name}"
    filesystem  = "${var.storage_block_device_format_filesystem}"
  }
}

data "template_file" "docker_wait_mount_dropin" {
  template = "${file("${path.module}/resources/dropins/01-wait-docker-mount.conf")}"

  vars {
    service_required = "${var.storage_block_device_mount ? "var-lib-docker.mount" : "local-fs.target"}"
  }
}

data "template_file" "docker_opts_dropin" {
  template = "${file("${path.module}/resources/dropins/10-dockeropts.conf")}"
}

data "template_file" "docker_proxy_dropin" {
  template = "${file("${path.module}/resources/dropins/99-proxy.conf")}"

  vars {
    http_proxy  = "${var.http_proxy}"
    https_proxy = "${var.https_proxy}"
    no_proxy    = "${var.no_proxy}"
  }
}

data "ignition_systemd_unit" "docker_mount" {
  name     = "var-lib-docker.mount"
  enabled  = "${var.storage_block_device_mount}"
  content  = "${data.template_file.docker_mount.rendered}"
}

data "ignition_systemd_unit" "docker_dropin" {
  name    = "docker.service"
  enabled = true

  dropin = [
    {
      name    = "01-wait-docker-mount.conf"
      content = "${data.template_file.docker_wait_mount_dropin.rendered}"
    },
    {
      name    = "10-dockeropts.conf"
      content = "${data.template_file.docker_opts_dropin.rendered}"
    },
    {
      name    = "99-proxy.conf"
      content = "${data.template_file.docker_proxy_dropin.rendered}"
    },
  ]
}

data "ignition_disk" "docker_storage_block_device" {
  count = "${var.storage_block_device_mount ? 1 : 0}"

  device     = "${var.storage_block_device_name}"
  wipe_table = true
}

data "ignition_filesystem" "docker_storage_filesystem" {
  count = "${var.storage_block_device_mount ? 1 : 0}"

  name = "docker"

  mount {
    device = "${var.storage_block_device_name}"
    format = "${var.storage_block_device_format_filesystem}"
    wipe_filesystem = "${var.storage_block_device_format ? true : false}"
    options = ["-L", "docker"]
  }
}
