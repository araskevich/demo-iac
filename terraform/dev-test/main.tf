
module "k8s-master01" {
  source    = "../modules/centos-vm"
  vm_name   = "k8s-master01"
  ip_addr   = "192.168.122.11"
  mac_addr  = "52:54:00:2e:a9:87"
  # vm_memory = "2048"
  vm_memory = "8192"
  # vm_vcpu   = 2
  vm_vcpu   = 4
  image     = "../../test-data/images/CentOS-7-x86_64-GenericCloud.qcow2"
  disk_path = "/home/alexey/git-projects/demo-iac/test-data/volumes/terraform-provider-libvirt-pool-centos"
}

# module "k8s-node01" {
#   source    = "../modules/centos-vm"
#   vm_name   = "k8s-node01"
#   ip_addr   = "192.168.122.22"
#   mac_addr  = "52:54:00:96:11:73"
#   vm_memory = "2048"
#   vm_vcpu   = 2 
#   image     = "../../test-data/images/CentOS-7-x86_64-GenericCloud.qcow2"
#   disk_path = "/home/alexey/git-projects/demo-iac/test-data/volumes/terraform-provider-libvirt-pool-centos"  
# }
