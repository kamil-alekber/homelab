include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "git::git@github.com:kamil-alekber/homelab.git//home/modules/lxc?ref=${values.version}"
}

inputs = {
  desired_count     = values.desired_count
  target_node       = "node-1"
  host_prefix       = "k0s"
  ipv4_ip_start     = 100
  ssh_public_keys   = "~/.ssh/id_rsa"
  memory            = 4096
  cores             = 4
  swap              = 1024
}
