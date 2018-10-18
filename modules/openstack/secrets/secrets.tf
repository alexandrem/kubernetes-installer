resource "tls_private_key" "core" {
  algorithm = "RSA"
}

resource "openstack_compute_keypair_v2" "cluster_ssh_keypair" {
  name       = "${var.cluster_name}_keypair"
  public_key = "${tls_private_key.core.public_key_openssh}"
}

resource "null_resource" "export" {
  provisioner "local-exec" {
    command = "echo '${tls_private_key.core.private_key_pem}' > generated/id_rsa_core && chmod 0600 generated/id_rsa_core"
  }

  provisioner "local-exec" {
    command = "echo '${tls_private_key.core.public_key_openssh}' > generated/id_rsa_core.pub"
  }
}
