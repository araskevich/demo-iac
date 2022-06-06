variable "vm_name" {
  description = "The names of the VM to create"
  type = string
  # default = "k8s-master01"
}

variable "ip_addr" {
  description = "The IP addr for VM"
  type = string
  # default = "192.168.122.11"
}

variable "mac_addr" {
  description = "The MAC addr for VM" 
  type = string
  # default = "52:54:00:2e:a9:87"
}

variable "vm_memory" {
  description = "Allocate memory for VM"
  type = string
  # default = "2048"
}

variable "vm_vcpu" {
  description = "Allocate vCPU for VM"
  type = string
  # default = 2
}

variable "disk_path" {
  description = "path for libvirt pool"
  type = string
  # default = "/tmp/terraform-provider-libvirt-pool-centos"
}

variable "image" {
  description = "path for libvirt image"
  type = string
  # default = "./images/CentOS-7-x86_64-GenericCloud.qcow2"
}