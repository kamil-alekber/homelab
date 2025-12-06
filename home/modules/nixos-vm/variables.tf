# ---------------------------------------------------------------------------------------------------------------------
# META VARIABLES
# ---------------------------------------------------------------------------------------------------------------------
variable "desired_count" {
  description = "The number of NixOS VMs to create. Set to 0 to disable creation."
  type        = number
  default     = 1
}

# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "host_prefix" {
  description = "The hostname prefix for the VMs"
  type        = string
}

variable "ip_addresses" {
  description = "List of IP addresses for the VMs"
  type        = list(string)
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ---------------------------------------------------------------------------------------------------------------------
variable "target_node" {
  description = "The Proxmox node to create the VM on"
  type        = string
  default     = "node-1"
}

variable "cores" {
  description = "The number of CPU cores to allocate to the VM"
  type        = number
  default     = 2
}

variable "memory" {
  description = "The amount of memory (in MB) to allocate to the VM"
  type        = number
  default     = 2048
}

variable "disk_size" {
  description = "The size of the disk in GB"
  type        = number
  default     = 32
}

variable "datastore_id" {
  description = "The datastore ID for the VM disk"
  type        = string
  default     = "local-lvm"
}

variable "ssh_username" {
  description = "The SSH username to use for the VM"
  type        = string
  default     = "root"
}

variable "ssh_public_key" {
  description = "The SSH public key location"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "network_address" {
  description = "The network address for the VM"
  type        = string
  default     = "192.168.1.0/24"
}

variable "nixos_version" {
  description = "NixOS version to use"
  type        = string
  default     = "24.05"
}

variable "nixos_image_url" {
  description = "URL to NixOS cloud image"
  type        = string
  default     = "https://channels.nixos.org/nixos-24.05/latest-nixos-minimal-x86_64-linux.qcow2"
}
