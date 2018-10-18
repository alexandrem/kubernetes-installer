output "secgroup_master_names" {
  value = [
    "${openstack_compute_secgroup_v2.master.name}",
  ]
}

output "secgroup_master_ids" {
  value = [
    "${openstack_compute_secgroup_v2.master.id}",
  ]
}

output "secgroup_worker_names" {
  value = [
    "${openstack_compute_secgroup_v2.worker.name}",
  ]
}

output "secgroup_worker_ids" {
  value = [
    "${openstack_compute_secgroup_v2.worker.id}",
  ]
}
