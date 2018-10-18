# etcdadm init is always done on the first etcd node for simplicity
resource "null_resource" "etcd-init" {
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
    which etcdadm || {
      sudo docker rm -f etcd-init-bin
      pid=$(docker run -d --name etcd-init-bin polykube/tools:latest sleep 60) &&
      sudo mkdir -p /opt/bin &&
      sudo docker cp $$pid:/usr/bin/etcdadm /opt/bin/
    }
    etcdadm info || {
      export HTTP_PROXY=${var.http_proxy}
      export HTTPS_PROXY=${var.https_proxy}
      sudo -E etcdadm download
      unset HTTP_PROXY HTTPS_PROXY

      echo "Initializing new etcd cluster..."
      sudo etcdadm init
    }
EOF
    ]
  }

    # rsync or scp is required here because file provisioner cannot copy from remote
    provisioner "local-exec" {
    command = <<EOF
    mkdir -p generated/etcd/pki
    rsync -avz --rsync-path "sudo -u root rsync" -e "ssh ${element(var.node_ssh_ips, 0)} -i ${element(var.node_ssh_key_paths, 0)} -l ${element(var.node_ssh_users, 0)} -o StrictHostKeyChecking=false" :/etc/etcd/pki/ca.* generated/etcd/pki/;
EOF
  }
}

# # this is a trick to read content of dynamic files, we generate a json
# # with filenames then read those external variables later
data "external" "etcd-ca-files" {
  program = ["echo",
    "{",
    "\"ca_crt\": \"${path.module}/generated/etcd/pki/ca.crt\",",
    "\"ca_key\": \"${path.module}/generated/etcd/pki/ca.key\"",
    "}",
  ]

  depends_on = [
    "null_resource.etcd-init",
  ]
}

resource "null_resource" "etcd-join" {
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

  # provisioner "remote-exec" {
  #   inline = ["sudo mkdir -p /etc/etcd/pki"]
  # }

  # provisioner "file" {
  #   content = "${file(lookup(data.external.etcd-ca-files.result, "ca_crt"))}"
  #   destination = "/etc/etcd/pki/ca.crt"
  # }

  # provisioner "file" {
  #   content = "${file(lookup(data.external.etcd-ca-files.result, "ca_key"))}"
  #   destination = "/etc/etcd/pki/ca.key"
  # }

  # this is merely a trick to wait that remote host has ssh open and ready to accept connection,
  # otherwise the next local-exec with rsync might fail.
  provisioner "remote-exec" {
    inline = ["hostname -f"]
  }

  # we prefer rsync to terraform file provisioner because the later doesn't support impersonating root.
  # scp doesn't support sudo and that would require extra remote-exec steps.
  provisioner "local-exec" {
    command = <<EOF
rsync -avz --rsync-path "sudo -u root rsync" \
 -e "ssh ${element(var.node_ssh_ips, count.index)} -i ${element(var.node_ssh_key_paths, count.index)} -l ${element(var.node_ssh_users, count.index)} \
 -o StrictHostKeyChecking=false" \
 generated/etcd/pki :/etc/etcd/;
EOF
  }

  provisioner "remote-exec" {
    
    inline = [<<EOF
    PATH=$PATH:/opt/bin
    # set -x

    which etcdadm || {
      sudo docker rm -f etcd-init-bin
      pid=$(docker run -d --name etcd-init-bin polykube/tools:latest sleep 60) &&
      sudo mkdir -p /opt/bin &&
      sudo docker cp $$pid:/usr/bin/etcdadm /opt/bin/
    }
    hostname -f

    function download_bin() {
      export HTTP_PROXY=${var.http_proxy}
      export HTTPS_PROXY=${var.https_proxy}
      sudo -E etcdadm download
      unset HTTP_PROXY HTTPS_PROXY
    }

    function clean_certs() {
      sudo mkdir -p /opt/etcd/pki
      sudo cp /etc/etcd/pki/ca.crt /opt/etcd/pki/
      sudo cp /etc/etcd/pki/ca.key /opt/etcd/pki/
      sudo rm -fr /etc/etcd/pki
      sudo mkdir -p /etc/etcd/pki
      sudo cp /opt/etcd/pki/ca.crt /etc/etcd/pki/
      sudo cp /opt/etcd/pki/ca.key /etc/etcd/pki/
    }

    sudo etcdadm info || {
      download_bin
      clean_certs

      PEERS=(${join(" ", var.node_ips)})
      local_ips=$$(ip r show table local | egrep '^local .* dev (eth|en).* scope host' | awk '{print $$2}')
      others=()
      for peer in $${PEERS[*]}; do
        if [[ ! " $${local_ips[@]} " =~ " $$peer " ]]; then
          others+=($$peer)
        fi
      done

      for peer in $${others[@]}; do
        echo "Attempting to join peer $$peer..."
        sudo etcdadm join https://$$peer:2379 && break
        echo "Failed to join." && false
      done

      sudo etcdadm info || {
        echo "ERROR: Failed to join cluster. Ensure this member $$(hostname -f) no longer exists before adding it back." && false
      }
    }
EOF
    ]
  }

    depends_on = [
    "null_resource.etcd-init",
  ]
}
