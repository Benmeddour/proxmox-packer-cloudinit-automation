# Ubuntu Server Noble (24.04.x)
# ---
# Packer Template to create an Ubuntu Server (Noble 24.04.x) on Proxmox

packer {
  required_plugins {
    proxmox = {
      version = " ~> 1.2.2"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

# Import variables from variables.pkr.hcl
# Variables can be overridden via command line or .pkrvars.hcl files

# Resource Definition for the VM Template
source "proxmox-iso" "ubuntu-server-noble-packer" {

    # Proxmox Connection Settings
    proxmox_url = var.proxmox_api_url
    username = var.proxmox_api_token_id
    password = var.proxmox_api_token_secret
    # (Optional) Skip TLS Verification
    insecure_skip_tls_verify = true

    # VM General Settings
    node = var.proxmox_node
    vm_id = var.vm_id
    template_name = var.vm_name
    template_description = var.template_description

    # VM OS Settings
    # Local ISO File
    iso {
        iso_file = var.iso_file
    }
    # Alternative: Download ISO (uncomment to use)
    # iso {
    #     iso_url = "https://releases.ubuntu.com/noble/ubuntu-24.04.2-live-server-amd64.iso"
    #     iso_checksum = var.iso_checksum
    # }

    # VM System Settings
    qemu_agent = true

    # VM Hard Disk Settings
    scsi_controller = "virtio-scsi-single"

    disks {
        cache_mode = "writeback"
        disk_size = var.disk_size
        storage_pool = var.storage_pool
        type = "scsi"
        format = "raw"
        io_thread = true
        discard = false
    }

    # VM CPU Settings
    cores = var.vm_cores
    sockets = var.vm_sockets

    # VM Memory Settings
    memory = var.vm_memory

    # VM Network Settings
    network_adapters {
        model = "virtio"
        bridge = var.network_bridge
        firewall = "false"
    }

    # VM Cloud-Init Settings
    cloud_init = true
    cloud_init_storage_pool = var.storage_pool
    
    

    # PACKER Boot Commands
    boot_command = [
        "<esc><wait><esc><wait>",
        "<f6><wait><esc><wait>",
        "<bs><bs><bs><bs><bs>",
        "<enter><wait>",
        "autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ",
        "--- <enter>"
    ]
    boot = "c"
    boot_wait = var.boot_wait
    communicator = "ssh"

    # PACKER Autoinstall Settings
    http_directory = "./http"
    # HTTP server configuration
    http_bind_address = var.http_bind_address
    http_port_min = var.http_port
    http_port_max = var.http_port

    ssh_username = var.ssh_username
    ssh_password = var.ssh_password
    # Alternative: SSH key authentication
    # ssh_private_key_file = "./ssh/id_rsa"

    # Timeouts
    ssh_timeout = var.ssh_timeout
    ssh_pty = true
}

# Build Definition to create the VM Template
build {

    name = "ubuntu-server-noble-packer"
    sources = ["source.proxmox-iso.ubuntu-server-noble-packer"]

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo truncate -s 0 /etc/machine-id",
            "sudo apt -y autoremove --purge",
            "sudo apt -y clean",
            "sudo apt -y autoclean",
            "sudo cloud-init clean",
            "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
            "sudo rm -f /etc/netplan/00-installer-config.yaml",
            "sudo sync"
        ]
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
    provisioner "file" {
        source = "./files/99-pve.cfg"
        destination = "/tmp/99-pve.cfg"
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
    provisioner "shell" {
        inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
    }

    # Add additional provisioning scripts here
    # ...
}
