include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "git::git@github.com:kamil-alekber/homelab.git//home/modules/vm?ref=${values.version}"
}

inputs = {
  # Required inputs
  name              = "k0s-node-1"
  target_node       = "node-1"
}

