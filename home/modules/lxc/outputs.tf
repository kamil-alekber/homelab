output "network_info" {
  value = proxmox_lxc.basic.network
  sensitive = false
}