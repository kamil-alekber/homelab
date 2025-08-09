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


variable "target_node" {
  description = "The Proxmox node to create the LXC on"
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "password" {
  description = "The password for the root user of the LXC"
  type        = string
  default     = "goodlife"
}

variable "unprivileged" {
  description = "Whether to create an unprivileged container"
  type        = bool
  default     = true
}

variable "rootfs_storage" {
  description = "The storage to use for the root filesystem"
  type        = string
  default     = "local-lvm"
}

variable "rootfs_size" {
  description = "The size of the root filesystem"
  type        = string
  default     = "12G"
}


variable "ostemplate" {
  description = "The OS template to use for the LXC container"
  type        = string
  default     = "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.gz"
  
}

variable "cores" {
  description = "The number of CPU cores to allocate to the LXC container"
  type        = number
  default     = 1
}

variable "memory" {
  description = "The amount of memory (in MB) to allocate to the LXC container"
  type        = number
  default     = 512
}

variable "swap" {
  description = "The amount of swap (in MB) to allocate to the LXC container"
  type        = number
  default     = 256
}

variable "start" {
  description = "Whether to start the LXC container after creation"
  type        = bool
  default     = true
}


### Network Variables
variable "vnic_name" {
  description = "Networking adapter name."
  type        = string
  default     = "eth0"
}

variable "vnic_bridge" {
  description = "Networking adapter bridge, e.g. `LXCbr0`."
  type        = string
  default     = "vmbr0"
}

variable "vlan_tag" {
  description = "Networking adapter VLAN tag."
  type        = number
  default     = 0
}

variable "ipv4_network" {
  description = "IPv4 network part e.g. `192.168.8`."
  type        = string
  default     = "192.168.8"
}

variable "ipv4_ip_start" {
  description = "IPv4 IP start part e.g. `100`."
  type        = number
  default     = 100
}

variable "dns_domain" {
  description = "Defaults to using PVE host setting."
  type        = string
  default     = null
}

variable "dns_server" {
  description = "Defaults to using PVE host setting."
  type        = string
  default     = null
}

variable "user_ssh_key_public" {
  description = "Public SSH Key for LXC user."
  default     = null
  type        = string
  sensitive   = true
  validation {
    condition     = can(regex("(?i)PRIVATE", var.user_ssh_key_public)) == false
    error_message = "Error: Private SSH Key."
  }
}


variable "os_type" {
  description = "Container OS specific setup, uses setup scripts in `/usr/share/lxc/config/<ostype>.common.conf`."
  type        = string
  default     = "unmanaged"
  validation {
    condition     = contains(["alpine", "archlinux", "centos", "debian", "devuan", "fedora", "gentoo", "nixos", "opensuse", "ubuntu", "unmanaged"], var.os_type)
    error_message = "Invalid OS type setting."
  }
}
