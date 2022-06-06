terraform {
  required_version = ">= 1.0.1"
  required_providers {
    libvirt = {
      source = "registry.terraform.io/dmacvicar/libvirt"
      version = "0.6.14"
    }
  }
}

# instance the provider
provider "libvirt" {
  uri = "qemu:///system"
  # uri = "qemu+ssh://root@192.168.1.2/system"
}

resource "libvirt_pool" "centos" {
  name = "${var.vm_name}-centos"
  type = "dir"
  path = "${var.disk_path}-${var.vm_name}"
}

# We fetch the latest centos release image from their mirrors
resource "libvirt_volume" "centos-qcow2" {
  name   = "${var.vm_name}-centos.qcow2"
  pool   = libvirt_pool.centos.name
  source = "${var.image}"
  # source = "http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2"
  # source = "file:///images/CentOS-7-x86_64-GenericCloud.qcow2"
  # source = "${path.module}/images/CentOS-7-x86_64-GenericCloud.qcow2"
  format = "qcow2"
}

# for more info about paramater check this out
# https://github.com/dmacvicar/terraform-provider-libvirt/blob/master/website/docs/r/cloudinit.html.markdown
# Use CloudInit to add our ssh-key to the instance
# you can add also meta_data field
resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "commoninit-${var.vm_name}.iso"
  user_data      = templatefile("${path.module}/templates/cloud_init.tpl", {
    hostname  = var.vm_name
    auth_key  = file("/home/devops/.ssh/id_rsa.pub")
  })
  network_config = templatefile("${path.module}/templates/network_config.tpl", {
    ip_addr  = var.ip_addr
    mac_addr = var.mac_addr
  })
  pool           = libvirt_pool.centos.name
}

# Create the machine
resource "libvirt_domain" "domain-centos" {
  name   = var.vm_name
  memory = var.vm_memory
  vcpu   = var.vm_vcpu

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name   = "default"
    addresses      = [var.ip_addr]
    mac            = var.mac_addr
    wait_for_lease = false
  }

  # IMPORTANT: this is a known bug on cloud images, since they expect a console
  # we need to pass it
  # https://bugs.launchpad.net/cloud-images/+bug/1573095
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.centos-qcow2.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

}
