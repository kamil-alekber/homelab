# ---------------------------------------------------------------------------------------------------------------------
# META VARIABLES (scaling)
# ---------------------------------------------------------------------------------------------------------------------
variable "desired_count" {
  description = "Number of VMs to create. Set to 0 to disable creation."
  type        = number
  default     = 1
}

# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name of the VM (used when desired_count=1). For multiple VMs use host_prefix."
  type        = string
  default     = null
}

variable "host_prefix" {
  description = "Hostname prefix when desired_count > 1 (result: <host_prefix>-<index>)." 
  type        = string
  default     = null
}

variable "target_node" {
  description = "The Proxmox node to create the VM on"
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "vmid" {
  description = "The ID of the VM (single VM mode only)"
  type        = number
  default     = 0
}

variable "onboot" {
  description = "Whether the VM should start on boot"
  type        = bool
  default     = true
}


variable "storage" {
  description = "The storage to use for the VM"
  type        = string
  default     = "local-lvm"
}

variable "cores" {
  description = "The number of CPU cores for the VM"
  type        = number
  default     = 2
}

variable "memory" {
  description = "The amount of memory (RAM) for the VM"
  type        = number
  default     = 2048
}

variable "tags" {
  description = "Tags to apply to the VM"
  type        = list(string)
  default     = ["vm-test", "k8s"]
}

variable "template" {
  description = "The template to clone the VM from"
  type        = string
  default     = "alpine-template"
}

variable "full_clone" {
  description = "Whether to use a full clone of the template (default: false)"
  type        = bool
  default     = true
  
}

# ---------------------------------------------------------------------------------------------------------------------
# NETWORK (Static IP)
# ---------------------------------------------------------------------------------------------------------------------
variable "ipv4_network" {
  description = "IPv4 network prefix without last octet e.g. 192.168.8. Leave null for DHCP."
  type        = string
  default     = null
}

variable "ipv4_ip" {
  description = "Host part (last octet) for static IPv4 address (single VM mode). Ignored if ipv4_network is null or desired_count>1."
  type        = number
  default     = null
}

variable "ipv4_ip_start" {
  description = "Starting host part for static IPs when desired_count>1 (e.g. 100 -> 192.168.8.100,101,...)."
  type        = number
  default     = 100
}

variable "ipv4_cidr" {
  description = "CIDR mask size for the IPv4 network"
  type        = number
  default     = 24
}

variable "ipv4_gateway" {
  description = "Gateway IPv4 address. Defaults to <ipv4_network>.1 when unset."
  type        = string
  default     = null
}