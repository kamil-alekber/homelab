include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "git::git@github.com:kamil-alekber/homelab.git//home/modules/lxc?ref=${values.version}"
}

inputs = {
  # Required inputs
  hostname          = "k0s-node-1"
  target_node       = "node-1"

  ipv4_address      = "192.168.8.101/24"
  ipv4_gateway      = "192.168.8.1"

  desired_count     = values.desired_count
}