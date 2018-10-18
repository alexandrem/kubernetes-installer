# kubeadm init is always done on the first master node for simplicity
resource "null_resource" "kube-init" {
  connection {
      type        = "ssh"
      host        = "${element(var.node_ssh_ips, 0)}"
      user        = "${element(var.node_ssh_users, 0)}"
      private_key = "${file(element(var.node_ssh_key_paths, 0))}"
      port        = 22
  }

  provisioner "remote-exec" {
    
    inline = [<<EOF
    PATH=$PATH:/opt/bin
    #set -x
    which kubeadm || {
      sudo docker rm -f kube-init-bin
      pid=$(docker run -d --name kube-init-bin polykube/tools:latest sleep 60) &&
      sudo mkdir -p /opt/bin &&
      sudo docker cp $$pid:/usr/bin/kubeadm /opt/bin/
    }
    
EOF
    ]
  }

    # rsync or scp is required here because file provisioner cannot copy from remote
    provisioner "local-exec" {
    command = <<EOF
    mkdir -p generated/etcd/pki
    #rsync -avz --rsync-path "sudo -u root rsync" -e "ssh ${element(var.node_ssh_ips, 0)} -i ${element(var.node_ssh_key_paths, 0)} -l ${element(var.node_ssh_users, 0)} -o StrictHostKeyChecking=false" :/etc/kubernetes/pki/ca.* generated/etcd/pki/;
EOF
  }
}

# # this is a trick to read content of dynamic files, we generate a json
# # with filenames then read those external variables later
data "external" "kube-ca-files" {
  program = ["echo",
    "{",
    "\"ca_crt\": \"${path.module}/generated/master/pki/ca.crt\",",
    "\"ca_key\": \"${path.module}/generated/master/pki/ca.key\"",
    "}",
  ]

  depends_on = [
    "null_resource.kube-init",
  ]
}

resource "null_resource" "kube-join" {
  count = "${var.count}"

  triggers {
    etcd = "${var.refresh_trigger}"
  }

  connection {
      type        = "ssh"
      host        = "${element(var.node_ssh_ips, count.index)}"
      user        = "${element(var.node_ssh_users, length(var.node_ssh_users)>1? count.index : 0)}"
      private_key = "${file(element(var.node_ssh_key_paths, length(var.node_ssh_key_paths)>1? count.index : 0))}"
      port        = 22
  }

  # this is merely a trick to wait that remote host has ssh open and ready to accept connection,
  # otherwise the next local-exec with rsync might fail.
  provisioner "remote-exec" {
    inline = ["hostname -f"]
  }

  # we prefer rsync to terraform file provisioner because the later doesn't support impersonating root.
  # scp doesn't support sudo and that would require extra remote-exec steps.
  provisioner "local-exec" {
    command = <<EOF
#rsync -avz --rsync-path "sudo -u root rsync" \
# -e "ssh ${element(var.node_ssh_ips, count.index)} -i ${element(var.node_ssh_key_paths, count.index)} -l ${element(var.node_ssh_users, count.index)} \
# -o StrictHostKeyChecking=false" \
# generated/master/pki :/etc/kubernetes/;
EOF
  }

  provisioner "remote-exec" {
    
    inline = [<<EOF
    PATH=$PATH:/opt/bin
    # set -x

    which kubeadm || {
      sudo docker rm -f kube-init-bin
      pid=$(docker run -d --name kube-init-bin polykube/tools:latest sleep 60) &&
      sudo mkdir -p /opt/bin &&
      sudo docker cp $$pid:/usr/bin/kubeadm /opt/bin/
    }
    hostname -f

EOF
    ]
  }

    depends_on = [
    "null_resource.kube-init",
  ]
}
