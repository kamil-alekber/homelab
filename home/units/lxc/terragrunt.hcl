include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "git::git@github.com:kamil-alekber/homelab.git//home/modules/lxc?ref=${values.version}"
}

inputs = {
  desired_count     = values.desired_count

  target_node       = values.target_node
  host_prefix       = values.host_prefix
  ipv4_ip_start     = values.ipv4_ip_start
}
