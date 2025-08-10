include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "git::git@github.com:kamil-alekber/homelab.git//home/modules/vm?ref=${values.version}"
}

inputs = {
  desired_count = values.desired_count
  host_prefix   = "k0s-node"
  target_node   = "node-1"

  # Optional static IP range start
  ipv4_network  = "192.168.8"
  ipv4_ip_start = 100
  ipv4_cidr     = 24
  template      = "alpine-template"
}

