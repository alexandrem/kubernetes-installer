output "ssh_user_id" {
  value = "${data.ignition_user.core.id}"
}

output "ssh_file_id" {
  value = "${data.ignition_file.sshd.id}"
}
