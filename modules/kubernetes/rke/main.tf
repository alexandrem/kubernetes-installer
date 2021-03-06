data template_file "ext_etcd" {
  template = <<EOF
path: /registry
external_urls:
  - ${indent(2, join("\n- ", split(",", var.external_etcd_urls)))}
ca_cert: |-
  ${indent(2, var.etcd_ca)}
cert: |-
  ${indent(2, var.etcd_cert)}
key: |-
  ${indent(2, var.etcd_key)}
EOF
}

data template_file "rke" {
  template = "${file("${path.module}/templates/rke-minimal.yml")}"

  vars {
    nodes                  = "${lookup(data.external.rke.result, "rke_template_nodes")}"
    cluster_name           = "${var.cluster_name}"
    kubernetes_version     = "${var.kubernetes_version == ""? "" : format("kubernetes_version: %s", var.kubernetes_version)}"
    cluster_pod_cidr       = "${var.cluster_pod_cidr}"
    cluster_dns_server     = "${var.cluster_dns_server}"
    cluster_service_cidr   = "${var.cluster_service_cidr}"
    cloud_provider         = "${var.cloud_provider}"
    openstack_cloud_config = "${var.cloud_provider == "openstack"? indent(2, local.openstack_cloud_config) : ""}"
    service_etcd           = "${indent(4, data.template_file.ext_etcd.rendered)}"
    ignore_docker_version  = "${var.ignore_docker_version? "true" : "false"}"
    api_extra_args         = "${indent(6, lookup(data.external.api_extra_args.result, "yaml"))}"
    controller_extra_args  = "${indent(6, lookup(data.external.controller_extra_args.result, "yaml"))}"
    kubelet_extra_args     = "${indent(6, lookup(data.external.kubelet_extra_args.result, "yaml"))}"
    network_plugin         = "${var.network_plugin}"
    network_options        = "${indent(4, lookup(data.external.network_options.result, "yaml"))}"
    ingress_provider       = "${var.ingress_provider}"
    addons_include         = "${length(var.addons_include)>0? format("- %s", indent(2, join("\n- ", var.addons_include))) : ""}"
  }
}

resource "null_resource" "pre_provision" {
  count = "${var.master_count + var.etcd_count + var.worker_count}"

  triggers = "${merge(
    var.refresh_trigger,
    map(
      "reprovision", "${var.force_provision? uuid() : ""}"
    ),
  )}"

  connection {
    host        = "${lookup(local.rke_node_objects[count.index], "address")}"
    private_key = "${file(lookup(local.rke_node_objects[count.index], "ssh_key_path"))}"
    user        = "${lookup(local.rke_node_objects[count.index], "user")}"
  }

  provisioner "remote-exec" {
    inline = [<<EOF
# RKE generates the ssl certs in different places...
sudo rm -fr /etc/kubernetes/.tmp
sudo rm -fr /opt/rke/etc/kubernetes/.tmp
sudo mkdir -p /etc/kubernetes/ssl /etc/kubernetes/.tmp
sudo mkdir -p /opt/rke/etc/kubernetes/ssl /opt/rke/etc/kubernetes/.tmp

# the "or true" is necessary for coreos where the curl script will return non zero
# because docker already exists.
# Not doing so will break terraform dependencies on pre_provision down the line
curl ${var.rke_install_script_url} | sh || true
EOF
    ]
  }

  # ensure to have up-to-date local etcd cert files
  provisioner "local-exec" {
    command = <<EOF
    ETCD_CA="${var.etcd_ca}"
    [[ ! -z $ETCD_CA ]] && echo "$$ETCD_CA" > generated/rke/pki/kube-etcd-client-ca.pem

    ETCD_KEY="${var.etcd_key}"
    [[ ! -z $ETCD_KEY ]] && echo "$$ETCD_KEY" > generated/rke/pki/kube-etcd-client-key.pem

    ETCD_CERT="${var.etcd_cert}"
    [[ ! -z $ETCD_CERT ]] && echo "$$ETCD_CERT" > generated/rke/pki/kube-etcd-client.pem
EOF
  }

  # Copy existing cert files (if any) to all nodes.
  # NOTE: We should probably only do this to remote control plane + etcd hosts. 
  provisioner "local-exec" {
    command = <<EOF
  # set -x
  [[ -f generated/rke/pki/kube-ca.pem ]] || exit 0

  for path in "/etc/kubernetes/ssl" "/etc/kubernetes/.tmp" "/opt/rke/etc/kubernetes/ssl" "/opt/rke/etc/kubernetes/.tmp"; do
    rsync -avz --rsync-path "sudo -u root rsync" \
      -e "ssh ${lookup(local.rke_node_objects[count.index], "address")} \
      -i ${lookup(local.rke_node_objects[count.index], "ssh_key_path")} \
      -l ${lookup(local.rke_node_objects[count.index], "user")} \
      -o StrictHostKeyChecking=false" \
      generated/rke/pki/* :$$path/;
  done
    EOF
  }

  provisioner "remote-exec" {
    inline = [<<EOF
# Fix last rsync permissions
for path in "/etc/kubernetes/ssl" "/etc/kubernetes/.tmp" "/opt/rke/etc/kubernetes/ssl" "/opt/rke/etc/kubernetes/.tmp"; do
  sudo chown -R root:root $$path
done
EOF
    ]
  }
}

resource "local_file" "rke" {
  content  = "${data.template_file.rke.rendered}"
  filename = "generated/cluster.yml"

  provisioner "local-exec" {
    command = "cd generated && rke up"
  }

  connection {
    host        = "${lookup(local.rke_node_objects[0], "address")}"
    private_key = "${file(lookup(local.rke_node_objects[0], "ssh_key_path"))}"
    user        = "${lookup(local.rke_node_objects[0], "user")}"
  }

  # Obtain current RKE certs in the kubernetes datastore.
  # We prefer this approach since the remote path may change depending on the
  # host OS distro (e.g either /etc/kubernetes or /opt/rke/etc/kubernetes).
  # This also ensures that the remote Kubernetes api is healthy at that point.
  provisioner "local-exec" {
    command = <<EOF
mkdir -p generated/rke/pki

# check for linux or darwin
echo | base64 -D &> /dev/null && decode="base64 -D" || decode="base64 -d"

# copy kube CA files
kubectl --kubeconfig=generated/kube_config_cluster.yml get secrets -n kube-system kube-ca -o go-template='{{.data.Certificate}}' | $$decode > generated/rke/pki/kube-ca.pem
kubectl --kubeconfig=generated/kube_config_cluster.yml get secrets -n kube-system kube-ca -o go-template='{{.data.Key}}' | $$decode > generated/rke/pki/kube-ca-key.pem

# copy etcd client files
kubectl --kubeconfig=generated/kube_config_cluster.yml get secrets -n kube-system kube-etcd-client-ca -o go-template='{{.data.Certificate}}' | $$decode > generated/rke/pki/kube-etcd-client-ca.pem
kubectl --kubeconfig=generated/kube_config_cluster.yml get secrets -n kube-system kube-etcd-client -o go-template='{{.data.Certificate}}' | $$decode > generated/rke/pki/kube-etcd-client.pem
kubectl --kubeconfig=generated/kube_config_cluster.yml get secrets -n kube-system kube-etcd-client -o go-template='{{.data.Key}}' | $$decode > generated/rke/pki/kube-etcd-client-key.pem

# kube-admin
kubectl --kubeconfig=generated/kube_config_cluster.yml get secrets -n kube-system kube-admin -o go-template='{{.data.Certificate}}' | $$decode > generated/rke/pki/kube-admin.pem
kubectl --kubeconfig=generated/kube_config_cluster.yml get secrets -n kube-system kube-admin -o go-template='{{.data.Key}}' | $$decode > generated/rke/pki/kube-admin-key.pem
kubectl --kubeconfig=generated/kube_config_cluster.yml get secrets -n kube-system kube-admin -o go-template='{{.data.Config}}' | $$decode > generated/rke/pki/kubecfg-kube-admin.yaml

# api
kubectl --kubeconfig=generated/kube_config_cluster.yml get secrets -n kube-system kube-apiserver -o go-template='{{.data.Certificate}}' | $$decode > generated/rke/pki/kube-apiserver.pem
kubectl --kubeconfig=generated/kube_config_cluster.yml get secrets -n kube-system kube-apiserver -o go-template='{{.data.Key}}' | $$decode > generated/rke/pki/kube-apiserver-key.pem

# api proxy
kubectl --kubeconfig=generated/kube_config_cluster.yml get secrets -n kube-system kube-apiserver-proxy-client -o go-template='{{.data.Certificate}}' | $$decode > generated/rke/pki/kube-apiserver-proxy-client.pem
kubectl --kubeconfig=generated/kube_config_cluster.yml get secrets -n kube-system kube-apiserver-proxy-client -o go-template='{{.data.Key}}' | $$decode > generated/rke/pki/kube-apiserver-proxy-client-key.pem
kubectl --kubeconfig=generated/kube_config_cluster.yml get secrets -n kube-system kube-apiserver-proxy-client -o go-template='{{.data.Config}}' | $$decode > generated/rke/pki/kubecfg-kube-apiserver-proxy-client.yaml

# api requestheader
kubectl --kubeconfig=generated/kube_config_cluster.yml get secrets -n kube-system kube-apiserver-requestheader-ca -o go-template='{{.data.Certificate}}' | $$decode > generated/rke/pki/kube-apiserver-requestheader-ca.pem
kubectl --kubeconfig=generated/kube_config_cluster.yml get secrets -n kube-system kube-apiserver-requestheader-ca -o go-template='{{.data.Key}}' | $$decode > generated/rke/pki/kube-apiserver-requestheader-ca-key.pem
kubectl --kubeconfig=generated/kube_config_cluster.yml get secrets -n kube-system kube-apiserver-requestheader-ca -o go-template='{{.data.Config}}' | $$decode > generated/rke/pki/kubecfg-kube-apiserver-requestheader-ca.yaml

# controller-manager
kubectl --kubeconfig=generated/kube_config_cluster.yml get secrets -n kube-system kube-controller-manager -o go-template='{{.data.Certificate}}' | $$decode > generated/rke/pki/kube-controller-manager.pem
kubectl --kubeconfig=generated/kube_config_cluster.yml get secrets -n kube-system kube-controller-manager -o go-template='{{.data.Key}}' | $$decode > generated/rke/pki/kube-controller-manager-key.pem
kubectl --kubeconfig=generated/kube_config_cluster.yml get secrets -n kube-system kube-controller-manager -o go-template='{{.data.Config}}' | $$decode > generated/rke/pki/kubecfg-kube-controller-manager.yaml

# node
kubectl --kubeconfig=generated/kube_config_cluster.yml get secrets -n kube-system kube-node -o go-template='{{.data.Certificate}}' | $$decode > generated/rke/pki/kube-node.pem
kubectl --kubeconfig=generated/kube_config_cluster.yml get secrets -n kube-system kube-node -o go-template='{{.data.Key}}' | $$decode > generated/rke/pki/kube-node-key.pem
kubectl --kubeconfig=generated/kube_config_cluster.yml get secrets -n kube-system kube-node -o go-template='{{.data.Config}}' | $$decode > generated/rke/pki/kubecfg-kube-node.yaml

# proxy
kubectl --kubeconfig=generated/kube_config_cluster.yml get secrets -n kube-system kube-proxy -o go-template='{{.data.Certificate}}' | $$decode > generated/rke/pki/kube-proxy.pem
kubectl --kubeconfig=generated/kube_config_cluster.yml get secrets -n kube-system kube-proxy -o go-template='{{.data.Key}}' | $$decode > generated/rke/pki/kube-proxy-key.pem
kubectl --kubeconfig=generated/kube_config_cluster.yml get secrets -n kube-system kube-proxy -o go-template='{{.data.Config}}' | $$decode > generated/rke/pki/kubecfg-kube-proxy.yaml

# scheduler
kubectl --kubeconfig=generated/kube_config_cluster.yml get secrets -n kube-system kube-scheduler -o go-template='{{.data.Certificate}}' | $$decode > generated/rke/pki/kube-scheduler.pem
kubectl --kubeconfig=generated/kube_config_cluster.yml get secrets -n kube-system kube-scheduler -o go-template='{{.data.Key}}' | $$decode > generated/rke/pki/kube-scheduler-key.pem
kubectl --kubeconfig=generated/kube_config_cluster.yml get secrets -n kube-system kube-scheduler -o go-template='{{.data.Config}}' | $$decode > generated/rke/pki/kubecfg-kube-scheduler.yaml
EOF
  }

  depends_on = [
    "null_resource.pre_provision",
  ]
}
