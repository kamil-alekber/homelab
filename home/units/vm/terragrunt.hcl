include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  // source = "git::git@github.com:kamil-alekber/homelab.git//home/modules/vm?ref=${values.version}"
  source = "../../modules/vm"
}

inputs = {
  desired_count = 5
  host_prefix   = "k0s-node"
  target_node   = "node-1"

}

