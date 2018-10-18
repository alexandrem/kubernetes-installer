data "ignition_config" "node" {
  users = ["${concat(
    var.ign_users,
  )}"]

  disks = ["${concat(
    var.ign_disks,
  )}"]

  files = ["${concat(
    var.ign_files,
  )}"]

  filesystems = ["${concat(
    var.ign_filesystems,
  )}"]

  systemd = ["${concat(
    var.ign_systemd
  )}"]

  networkd = ["${concat(
    var.ign_networkd
  )}"]
}
