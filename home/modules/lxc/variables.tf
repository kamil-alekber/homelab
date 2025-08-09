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

variable "hostname" {
  description = "The hostname of the VM"
  type        = string
}


variable "target_node" {
  description = "The Proxmox node to create the VM on"
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "password" {
  description = "The password for the root user of the VM"
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
  default     = "local:vztmpl/alpine-3.21-default_20241217_amd64.tar.xz"
  
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
  description = "Networking adapter bridge, e.g. `vmbr0`."
  type        = string
  default     = "vmbr0"
}

variable "vlan_tag" {
  description = "Networking adapter VLAN tag."
  type        = number
  default     = 0
}

variable "ipv4_address" {
  description = "Defaults to DHCP, for static IPv4 address set CIDR."
  type        = string
  default     = "dhcp"
}

variable "ipv4_gateway" {
  description = "Defaults to DHCP, for static IPv4 gateway set IP address."
  type        = string
  default     = null
}

variable "ipv6_address" {
  description = "Defaults to DHCP, for static IPv6 address set CIDR."
  type        = string
  default     = "dhcp"
}

variable "ipv6_gateway" {
  description = "Defaults to DHCP, for static IPv6 gateway set IP address."
  type        = string
  default     = null
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