# IPs: if DHCP set, use wait_for_lease true or after creation use terraform refresh and terraform show for the ips of domain

 output "hosts" {
   description = "List of deployed VMs"
   value = zipmap(libvirt_domain.domain-centos[*].name, libvirt_domain.domain-centos[*].network_interface[0].addresses)
 }

# output "ip" {
#   value = libvirt_domain.domain-centos.network_interface[0].addresses[0]
# }
# output "hosts" {
#   description = "List of deployed VMs"
#   value = zipmap(libvirt_domain.domain-centos.*.name, libvirt_domain.domain-centos.*.network_interface.0.addresses)
# }
