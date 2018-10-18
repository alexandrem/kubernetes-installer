data "ignition_systemd_unit" "networkd" {
  name = "systemd-networkd.service"
}

data "ignition_networkd_unit" "eth0" {
  name = "00-eth0.network"

  content = <<EOF
[Match]
Name=eth0

[Network]
DHCP=ipv4

[DHCP]
RouteMetric=${var.eth0_route_metric}
UseDNS=${var.eth0_dhcp_use_dns}
EOF
}

data "ignition_networkd_unit" "eth1" {
  name = "01-eth1.network"

  content = <<EOF
[Match]
Name=eth1

[Network]
DHCP=ipv4

[DHCP]
RouteMetric=${var.eth1_route_metric}
UseDNS=${var.eth1_dhcp_use_dns}
EOF
}
