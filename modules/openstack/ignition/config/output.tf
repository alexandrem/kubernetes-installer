output "user_data" {
  value = "${element(data.ignition_config.node.*.rendered, 0)}"
}
