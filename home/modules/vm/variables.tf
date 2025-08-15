# ---------------------------------------------------------------------------------------------------------------------
# META VARIABLES
# ---------------------------------------------------------------------------------------------------------------------
variable "desired_count" {
  description = "The number of LXC containers to create. Set to 0 to disable creation."
  type        = number
  default     = 1
}

# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "host_prefix" {
  description = "The hostname prefix for the LXC containers"
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ---------------------------------------------------------------------------------------------------------------------
variable "target_node" {
  description = "The Proxmox node to create the LXC on"
  type        = string
  default     = "node-1"
}

variable "cores" {
  description = "The number of CPU cores to allocate to the LXC container"
  type        = number
  default     = 2
}

variable "memory" {
  description = "The amount of memory (in MB) to allocate to the LXC container"
  type        = number
  default     = 2048
}

variable "ssh_username" {
  description = "The SSH username to use for the LXC container"
  type        = string
  default     = "kamil"
}

variable "ssh_public_key" {
  description = "The SSH public key location"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}


variable "network_address" {
  description = "The network address for the LXC container"
  type        = string
  default     = "192.168.8.0/24"
}

variable "ip_start_range" {
  description = "The starting IP address for the LXC container"
  type        = number
  default     = 100
}
