# Proxmox Packer Cloudinit Automation

This repository contains Packer templates for automating the creation of virtual machine templates on Proxmox Virtual Environment (PVE). The project focuses on building Ubuntu Server 24.04 LTS (Noble) templates with Cloud-Init integration for infrastructure automation. you can find more details in the [README1.md](README1.md) file.

## 🎯 The Problem We Solve

Manually configuring each cloud instance—setting hostnames, creating users, configuring SSH keys, and installing necessary packages—can quickly become a nightmare, especially when dealing with multiple servers, virtual machines, or cloud instances. The process of managing and configuring these instances can be both complex and time-consuming.

**This project combines Packer and Cloud-Init to provide end-to-end automation:**
- **Cloud-Init** handles instance customization during first boot
- **Packer** automates the creation of the VM templates themselves
- Together, they eliminate manual steps and ensure consistent, repeatable deployments

## � Table of Contents

- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Configuration](#configuration)
- [Usage](#usage)
- [Template Features](#template-features)
- [Background & Theory](#background--theory)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## 🚀 Quick Start

1. **Clone and setup:**
   ```powershell
   git clone <your-repo-url>
   cd Packer_cloud-int_automation
   ```

2. **Configure your environment:**
   ```powershell
   # Copy environment template and edit with your credentials
   copy .env.example .env
   notepad .env
   ```

## 📁 Project Structure

```
Packer_cloud-int_automation/
├── .env.example                         # Environment variables template
├── .gitignore                          # Git ignore rules
├── LICENSE                             # MIT License
├── README.md                           # This file
├── README1.md                          # Background theory and concepts
└── packer/
    └── proxmox/
        └── ubuntu-server-noble/
            ├── ubuntu-server-noble.pkr.hcl  # Main Packer template
            ├── variables.pkr.hcl             # Variable definitions
            ├── minimal-example.pkr.hcl       # Minimal working example
            ├── files/
            │   └── 99-pve.cfg               # Cloud-Init datasource config
            ├── http/
            │   └── user-data                # Cloud-Init user configuration
            └── ssh/
                └── README.md                # SSH key management guide
```

## 🔧 Prerequisites

### Software Requirements

- [HashiCorp Packer](https://www.packer.io/) (version >= 1.2.2)
- Proxmox Virtual Environment 7.0+
- Ubuntu 24.04.2 LTS ISO image
- Network connectivity to Proxmox host

### Proxmox Setup

1. **API Token**: Create a Proxmox API token with sufficient privileges
   - Navigate to Datacenter → Permissions → API Tokens
   - Create a new token for the Packer user (e.g., `Packer@pam!packerAPI`)
   - Grant appropriate permissions (VM.Allocate, VM.Config.*, etc.)
   - Note down the Token ID and Secret

2. **Storage Configuration**: Ensure the following storage pools are available:
   - `local`: For ISO images
   - `local-lvm`: For VM disks and Cloud-Init drives

3. **Network**: Verify network bridge `vmbr0` is configured and accessible

4. **ISO Upload**: Upload Ubuntu 24.04.2 LTS ISO to Proxmox storage

## ⚙️ Configuration

### 1. Environment Setup

Copy the example environment file and configure your settings:

```powershell
cp .env.example .env
```

Edit `.env` with your actual values:

> ⚠️ **Security Warning**: Never commit the `.env` file to version control. It contains sensitive credentials.

```bash
# Proxmox Connection Settings
PROXMOX_API_URL=https://192.168.1.38:8006/api2/json
PROXMOX_API_TOKEN_ID=Packer@pam!packerAPI
PROXMOX_API_TOKEN_SECRET=your-actual-token-secret

# VM Configuration (optional - defaults available)
VM_ID=102
PROXMOX_NODE=pmoxk8s
VM_NAME=ubuntu-server-noble-packer
HTTP_BIND_ADDRESS=192.168.1.36
HTTP_PORT=8802
SSH_USERNAME=admin
SSH_PASSWORD=admin
```

### 2. Template Configuration

Key configuration options can be customized in `variables.pkr.hcl` or via environment variables:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `vm_id` | VM template ID | `102` |
| `vm_name` | Template name | `ubuntu-server-noble-packer` |
| `node` | Target Proxmox node | `pmoxk8s` |
| `cores` | CPU cores | `2` |
| `sockets` | CPU sockets | `2` |
| `memory` | RAM in MB | `4096` |
| `disk_size` | Disk size | `32G` |

### 3. User Configuration

Customize the Cloud-Init user configuration in `http/user-data`. The template includes:

- Default user: `admin` with sudo privileges
- SSH key authentication (recommended for production)
- Password authentication (for testing - change in production)
- Essential packages pre-installed
- Custom MOTD and SSH configuration

## 🚀 Usage

### Manual Build

1. **Navigate to the template directory:**
   ```powershell
   cd .\packer\proxmox\ubuntu-server-noble
   ```

2. **Validate the template:**
   ```powershell
   packer validate .
   ```

3. **Build the template:**
   ```powershell
   packer build .
   ```


### Build Process

The build process includes:

1. **VM Creation**: Creates a new VM with specified configuration
2. **ISO Boot**: Boots from Ubuntu 24.04 LTS ISO
3. **Autoinstall**: Automated Ubuntu installation using Cloud-Init
4. **Provisioning**: 
   - Waits for Cloud-Init completion
   - Cleans up SSH host keys and machine ID
   - Installs Cloud-Init Proxmox integration
   - System cleanup and optimization
5. **Template Conversion**: Converts VM to template

## ✨ Template Features

### Pre-installed Packages

- `qemu-guest-agent`: Enhanced VM management and integration with Proxmox
- `sudo`: Administrative privileges
- `bash-completion`: Command completion for better UX
- `net-tools`: Network utilities (ifconfig, netstat, etc.)
- `command-not-found`: Helpful command suggestions
- `curl`, `wget`: HTTP clients for downloads
- `vim`, `htop`, `tree`: Essential system tools
- `git`: Version control

### Cloud-Init Integration

- **Datasources**: ConfigDrive and NoCloud support for Proxmox
- **Network**: Dynamic network configuration via Cloud-Init
- **Users**: Automated user creation with SSH key injection
- **Packages**: Dynamic package installation during first boot
- **Scripts**: Custom script execution capabilities
- **Files**: Ability to write custom configuration files

### Security Features

- SSH password authentication (configurable)
- SSH key-based authentication support
- Sudo access with NOPASSWD for automation (configurable)
- Disabled root login by default
- Clean machine ID for proper template cloning
- Custom SSH configuration with security hardening

### Proxmox Optimizations

- QEMU Guest Agent integration
- Proper Cloud-Init datasource configuration
- Virtio drivers for optimal performance
- Template-ready with cleaned system state

## 📚 Background & Theory

### The Problem with Manual Configuration

Manually configuring cloud instances involves repetitive tasks:
- Setting hostnames and network configuration
- Creating users and configuring SSH keys
- Installing necessary packages
- Configuring system settings

This process becomes unmanageable at scale and is prone to human error.

### Cloud-Init: Instance Initialization

**Cloud-Init** is an open-source initialization tool that automates the setup of cloud instances. It handles:

- **Networking**: IP addresses, DNS, routing configuration
- **Storage**: Disk and partition setup
- **SSH Keys**: Automated key deployment for secure access
- **Packages**: Software installation during first boot
- **Users**: Account creation and configuration

Cloud-Init detects the cloud environment and customizes the system accordingly, ensuring instances are immediately ready for use.

### Packer: Image Automation

**Packer** by HashiCorp automates the creation of machine images. It:

1. **Codifies Image Creation**: Define setup in configuration files
2. **Integrates with Cloud-Init**: Automatically inject configuration during build
3. **Runs Provisioning Scripts**: Install dependencies and configure settings
4. **Outputs Ready Templates**: Generate fully configured machine images

### Why Combine Cloud-Init with Packer?

1. **End-to-End Automation**: Packer creates templates, Cloud-Init customizes instances
2. **Version Control**: Store all configuration in Git for auditability
3. **Scalability**: Build identical templates for multiple platforms simultaneously
4. **Error Reduction**: Eliminate manual steps and human mistakes
5. **Consistency**: Ensure identical configurations across all deployments

## 🔍 Troubleshooting

### Common Issues

1. **Build Timeout**:
   ```
   Error: SSH timeout
   ```
   - Increase `ssh_timeout` in variables.pkr.hcl
   - Check network connectivity to Proxmox host
   - Verify HTTP server accessibility from VM
   - Check firewall rules

2. **Authentication Failures**:
   ```
   Error: 401 Unauthorized
   ```
   - Verify Proxmox API credentials in .env file
   - Check token permissions in Proxmox
   - Ensure token is not expired
   - Verify API URL is correct


3. **Cloud-Init Issues**:
   ```
   Error: Cloud-init failed to complete
   ```
   - Check user-data YAML syntax
   - Verify SSH key format if using key authentication
   - Check for special characters in passwords
   - Review VM console logs in Proxmox

4. **Storage Issues**:
   ```
   Error: Storage pool not found
   ```
   - Verify storage pool names in Proxmox
   - Check available disk space
   - Ensure proper storage permissions
   - Verify ISO file exists and is accessible

### Debug Mode

Enable comprehensive debugging:

```powershell
# Manual debug with Packer
$env:PACKER_LOG=1
packer build .
```

### Log Locations

- **Packer logs**: Check console output or `packer-build-*.log` files
- **VM console**: Available in Proxmox web interface
- **Cloud-Init logs**: `/var/log/cloud-init*.log` on the VM
- **SSH logs**: `/var/log/auth.log` on the VM

### Getting Help

1. Review Packer documentation: [https://packer.io/docs](https://packer.io/docs)
2. Consult Proxmox documentation: [https://pve.proxmox.com/pve-docs/](https://pve.proxmox.com/pve-docs/)
3. Check Cloud-Init documentation: [https://cloudinit.readthedocs.io/](https://cloudinit.readthedocs.io/)

## 📚 References & Learning Resources

### Videos
- [Getting Started with cloud-init](https://youtu.be/exeuvgPxd-E)
- [cloud-init: Building clouds one Linux box at a time](https://youtu.be/1joQfUZQcPg)
- [Create VMs on Proxmox in Seconds!](https://www.youtube.com/watch?v=1nf3WOEFq1Y&t=180s)
- [Perfect Proxmox Template with Cloud Image and Cloud-Init](https://youtu.be/shiIi38cJe4)

### Blogs & Guides
- [Create Proxmox cloud-init templates for use with Packer](https://dev.to/mike1237/create-proxmox-cloud-init-templates-for-use-with-packer-193a)
- [Step-by-Step Guide: Building Custom Proxmox Images with Packer](https://phiptech.com/step-by-step-guide-building-custom-proxmox-images-with-packer/)
- [Customized Ubuntu Images using Packer + QEMU + Cloud-Init & UEFI bootloading](https://shantanoo-desai.github.io/posts/technology/packer-ubuntu-qemu/)
- [Ubuntu Server 22.04 image with Packer and Subiquity for Proxmox](https://www.aerialls.eu/posts/ubuntu-server-2204-image-packer-subiquity-for-proxmox/)
- [Proxmox: Create a Cloud-init Template VM with Packer](https://ronamosa.io/docs/engineer/LAB/proxmox-packer-vm/)

### Official Documentation
- [Packer Documentation](https://developer.hashicorp.com/packer/docs/intro)
- [Cloud-Init Documentation](https://cloudinit.readthedocs.io/en/latest/)
- [Proxmox VE Documentation](https://pve.proxmox.com/wiki/Main_Page)


## � License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [HashiCorp Packer](https://www.packer.io/) for the automation framework
- [Proxmox VE](https://www.proxmox.com/) for the virtualization platform
- [Ubuntu](https://ubuntu.com/) for the base operating system
- [Cloud-Init](https://cloud-init.io/) for system initialization
- The open-source community for continuous inspiration


