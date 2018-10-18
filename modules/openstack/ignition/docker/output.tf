
output "systemd_docker_mount_id" {
  value = "${data.ignition_systemd_unit.docker_mount.id}"
}

output "systemd_docker_dropin_id" {
  value = "${data.ignition_systemd_unit.docker_dropin.id}"
}

output "disk_docker_storage_block_device_id" {
  value = "${join("", data.ignition_disk.docker_storage_block_device.*.id)}"
}

output "filesystem_docker_storage_filesystem_id" {
  value = "${join("", data.ignition_filesystem.docker_storage_filesystem.*.id)}"
}