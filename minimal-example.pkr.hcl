# Example configuration that matches official Packer Proxmox plugin docs
# This shows the minimal required configuration

variable "proxmox_password" {
  type      = string
  sensitive = true
}

variable "proxmox_username" {
  type = string
}

source "proxmox-iso" "ubuntu-example" {
  # Connection
  proxmox_url  = "https://your-proxmox:8006/api2/json"
  username     = var.proxmox_username
  password     = var.proxmox_password
  insecure_skip_tls_verify = true
  
  # VM Settings
  node = "your-node"
  vm_id = "999"
  template_name = "ubuntu-24-04-template"
  template_description = "Ubuntu 24.04 LTS template"
  
  # ISO
  iso {
    iso_file = "local:iso/ubuntu-24.04.2-live-server-amd64.iso"
  }
  
  # Hardware
  cores  = "2"
  memory = "2048"
  
  disks {
    type         = "scsi"
    disk_size    = "20G"
    storage_pool = "local-lvm"
  }
  
  network_adapters {
    model  = "virtio"
    bridge = "vmbr0"
  }
  
  # Cloud-Init
  cloud_init = true
  cloud_init_storage_pool = "local-lvm"
  
  # Boot
  boot_wait = "5s"
  boot_command = [
    "<esc><wait><esc><wait>",
    "<f6><wait><esc><wait>",
    "<bs><bs><bs><bs><bs>",
    "<enter><wait>",
    "autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ",
    "--- <enter>"
  ]
  
  # SSH
  ssh_username = "ubuntu"
  ssh_password = "ubuntu"
  ssh_timeout = "20m"
  
  # HTTP
  http_directory = "http"
}

build {
  sources = ["source.proxmox-iso.ubuntu-example"]
}
