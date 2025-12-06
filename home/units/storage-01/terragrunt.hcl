include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../modules/nixos-vm"
}

inputs = {
  desired_count = 1
  host_prefix   = "storage"
  target_node   = "node-1"
  cores         = 2
  memory        = 4096
  disk_size     = 100
  ip_addresses  = ["192.168.1.20"]
  network_address = "192.168.1.0/24"
}
