data "ignition_user" "core" {
  name                = "core"
  ssh_authorized_keys = ["${var.ssh_public_keys}"]
}

data "ignition_file" "sshd" {
  filesystem = "root"
  path       = "/etc/ssh/sshd_config"
  mode       = 0600

  content {
    content = <<EOF
UsePrivilegeSeparation sandbox
Subsystem sftp internal-sftp

PermitRootLogin no
AuthenticationMethods publickey
EOF
  }
}