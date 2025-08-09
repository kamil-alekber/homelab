output "network_info" {
  value = proxmox_lxc.basic-[*].network.ip
  sensitive = false
}