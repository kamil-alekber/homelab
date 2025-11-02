include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../modules/nixos-vm"
}

inputs = {
  desired_count = 2
  host_prefix   = "k3s-agent"
  target_node   = "node-1"
  cores         = 4
  memory        = 8192
  disk_size     = 50
  ip_addresses  = ["192.168.1.22", "192.168.1.23"]
  network_address = "192.168.1.0/24"
}
