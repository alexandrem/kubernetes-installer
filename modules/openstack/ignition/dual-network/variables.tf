variable "eth0_route_metric" {
    type = "string"
    default = "10"
}

variable "eth0_dhcp_use_dns" {
    default = "true"
}

variable "eth1_route_metric" {
    type = "string"
    default = "100"
}

variable "eth1_dhcp_use_dns" {
    default = "false"
}
