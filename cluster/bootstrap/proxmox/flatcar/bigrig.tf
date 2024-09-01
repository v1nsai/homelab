terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.9.14"
    }
  }
}

provider "proxmox" {
  pm_api_url = var.proxmox_api_url
  pm_user = var.proxmox_user
  pm_password = var.proxmox_password
  pm_tls_insecure = true
}

variable "proxmox_api_url" {
  type = string
}

variable "proxmox_user" {
  type = string
}

variable "proxmox_password" {
  type = string
  sensitive = true
}

# Resource for the VM
resource "proxmox_vm_qemu" "vm" {
  name = "bigrig-flatcar-0"
  target_node = "bigrig"
  
  # VM Settings
  iso = "local:iso/flatcar_production_iso_image.iso"
  os_type = "l26"  # Linux 2.6+ kernel
  
  # Hardware settings
  cores = 8
  sockets = 1
  memory = 16384
  
  # Disk settings
  disk {
    size = "20G"
    type = "scsi"
    storage = "local-lvm"  # Replace with your storage name
    slot = 0
  }

  disk {
    type = "sata"
    file = "/dev/sdb"
    size = "0M"  # Size is set to 0 as it's an existing disk
    format = "raw"
    storage = "local-lvm"
    slot = 1
  }
  
  # Network settings (assuming default bridge)
  network {
    model = "virtio"
    bridge = "vmbr0"
  }
}