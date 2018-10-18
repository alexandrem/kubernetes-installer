variable "storage_block_device_mount" {
  description = "True to mount a block device to use for docker storage path"
  default     = false
}

variable "storage_block_device_name" {
  description = "Path of block device to use for docker storage"
  default     = "/dev/vdb"
}

variable "storage_block_device_format" {
  description = "Automatically format a block device that will serve for docker storage. Set to false if block device is a volume already formated."
  default     = true
}

variable "storage_block_device_format_filesystem" {
  description = "Filesystem to use for the block device format operation."
  default     = "ext4"
}

variable "http_proxy" {
  default = ""
  type    = "string"
}

variable "https_proxy" {
  default = ""
  type    = "string"
}

variable "no_proxy" {
  default = ""
  type    = "string"
}
