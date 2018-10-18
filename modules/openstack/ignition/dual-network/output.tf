output "systemd_networkd_id" {
  value = "${data.ignition_systemd_unit.networkd.id}"
}

output "networkd_eth0_id" {
  value = "${data.ignition_networkd_unit.eth0.id}"
}

output "networkd_eth1_id" {
  value = "${data.ignition_networkd_unit.eth1.id}"
}
