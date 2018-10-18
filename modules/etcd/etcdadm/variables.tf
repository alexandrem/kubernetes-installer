variable "node_ssh_ips" {
    type = "list"
    description = "List of ip addresses for ssh connection to etcd nodes."
}

variable "node_ssh_users" {
    type = "list"
    description = "List of ssh users for etcd nodes. If size of 1, then will use same user for all nodes."
}

variable "node_ssh_key_paths" {
    type = "list"
    description = "List of ssh key file paths for etcd nodes. If size of 1, then will use same key file for all nodes."
}

variable "node_ips" {
    type = "list"
    description = "List of etcd member ips. Usually private ip for peering. Must be part of the generated certificates SANs."
}

variable "count" {
    type = "string"
    description = "Number of etcd nodes to provision."
}

variable "refresh_trigger" {
    type = "string"
    description = "String to refresh etcd join. Should contain list of etcd instance ids."
}

variable "http_proxy" {
    type = "string"
    default = ""
}

variable "https_proxy" {
    type = "string"
    default = ""
}