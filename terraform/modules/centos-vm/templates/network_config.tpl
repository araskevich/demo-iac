# version: 2
# ethernets:
#   ens3:
#     dhcp4: true
#################

version: 2
ethernets:
  eth0:
    dhcp4: false
    address:
    - ${ip_addr}/24
    gateway4: 192.168.122.1
    match:
      macaddress: ${mac_addr}
    nameservers:
      addresses:
      - 192.168.122.1
    set-name: eth0
