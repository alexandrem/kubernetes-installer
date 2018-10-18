output "keypair_name" {
  value = "${var.cluster_name}_keypair"
}

output "core_private_key_pem" {
  value = "${tls_private_key.core.private_key_pem}"
}

output "core_public_key_openssh" {
  value = "${tls_private_key.core.public_key_openssh}"
}
