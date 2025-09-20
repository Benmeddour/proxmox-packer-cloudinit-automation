# Variables for Packer Template
# These can be overridden via command line or .pkrvars.hcl files

# Proxmox Connection Variables
variable "proxmox_api_url" {
  type        = string
  description = "Proxmox API URL"
}

variable "proxmox_api_token_id" {
  type        = string
  description = "Proxmox API Token ID"
}

variable "proxmox_api_token_secret" {
  type        = string
  description = "Proxmox API Token Secret"
  sensitive   = true
}

# VM Configuration Variables
variable "vm_id" {
  type        = string
  default     = "102"
  description = "VM ID for the template"
}

variable "vm_name" {
  type        = string
  default     = "ubuntu-server-noble-packer"
  description = "Name of the VM template"
}

variable "proxmox_node" {
  type        = string
  default     = "pmoxk8s"
  description = "Proxmox node name"
}

variable "template_description" {
  type        = string
  default     = "Ubuntu Server 24.04 LTS (Noble) with Cloud-Init and Packer"
  description = "Description for the VM template"
}

# Hardware Configuration
variable "vm_cores" {
  type        = string
  default     = "2"
  description = "Number of CPU cores"
}

variable "vm_sockets" {
  type        = string
  default     = "2"
  description = "Number of CPU sockets"
}

variable "vm_memory" {
  type        = string
  default     = "4096"
  description = "Amount of memory in MB"
}

variable "disk_size" {
  type        = string
  default     = "32G"
  description = "Size of the primary disk"
}

variable "storage_pool" {
  type        = string
  default     = "local-lvm"
  description = "Storage pool for VM disks"
}

variable "iso_storage_pool" {
  type        = string
  default     = "local"
  description = "Storage pool for ISO files"
}

# ISO Configuration
variable "iso_file" {
  type        = string
  default     = "local:iso/ubuntu-24.04.2-live-server-amd64.iso"
  description = "Path to Ubuntu ISO file on Proxmox"
}

variable "iso_url" {
  type        = string
  default     = "https://releases.ubuntu.com/noble/ubuntu-24.04.2-live-server-amd64.iso"
  description = "URL to download Ubuntu ISO (alternative to iso_file)"
}

variable "iso_checksum" {
  type        = string
  default     = "8762f7e74e4d64d72fceb5f70682e6b069932deedb4949c6975d0f0fe0a91be3"
  description = "SHA256 checksum of the ISO file"
}

# Network Configuration
variable "network_bridge" {
  type        = string
  default     = "vmbr0"
  description = "Network bridge to use"
}

variable "http_bind_address" {
  type        = string
  default     = "0.0.0.0"
  description = "IP address to bind HTTP server for autoinstall files"
}

variable "http_port" {
  type        = string
  default     = "8802"
  description = "Port for HTTP server"
}

# SSH Configuration
variable "ssh_username" {
  type        = string
  default     = "admin"
  description = "SSH username for provisioning"
}

variable "ssh_password" {
  type        = string
  default     = "admin"
  description = "SSH password for provisioning"
  sensitive   = true
}

variable "ssh_timeout" {
  type        = string
  default     = "30m"
  description = "SSH timeout for provisioning"
}

# Build Configuration
variable "boot_wait" {
  type        = string
  default     = "5s"
  description = "Time to wait before sending boot commands"
}
