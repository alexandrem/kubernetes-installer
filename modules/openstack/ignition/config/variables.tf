variable "count" {
    type = "string"
    default = "1"
}

variable "ign_users" {
    default = []
}

variable "ign_disks" {
    default = []
}

variable "ign_files" {
    default = []
}

variable "ign_filesystems" {
    default = []
}

variable "ign_systemd" {
    default = []
}

variable "ign_networkd" {
    default = []
}
