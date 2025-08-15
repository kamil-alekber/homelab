output "network_info" {
  value = [for vm in proxmox_lxc.basic : vm.network[0].ip]
  sensitive = false
}