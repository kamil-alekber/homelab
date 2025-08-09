# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name of the VM"
  type        = string
}

variable "target_node" {
  description = "The Proxmox node to create the VM on"
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "vmid" {
  description = "The ID of the VM"
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
  default     = "talos-base"
}