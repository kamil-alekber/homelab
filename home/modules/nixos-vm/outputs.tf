output "vm_ids" {
  description = "The IDs of the created VMs"
  value       = proxmox_virtual_environment_vm.nixos_vm[*].id
}

output "vm_names" {
  description = "The names of the created VMs"
  value       = proxmox_virtual_environment_vm.nixos_vm[*].name
}

output "vm_ip_addresses" {
  description = "The IP addresses of the created VMs"
  value       = var.ip_addresses
}
