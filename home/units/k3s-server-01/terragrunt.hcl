include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../modules/nixos-vm"
}

inputs = {
  desired_count = 1
  host_prefix   = "k3s-server"
  target_node   = "node-1"
  cores         = 4
  memory        = 8192
  disk_size     = 50
  ip_addresses  = ["192.168.1.21"]
  network_address = "192.168.1.0/24"
}
