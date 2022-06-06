#cloud-config
# vim: syntax=yaml
#
# ***********************
# 	---- for more examples look at: ------
# ---> https://cloudinit.readthedocs.io/en/latest/topics/examples.html
# ******************************
#
# This is the configuration syntax that the write_files module
# will know how to understand. encoding can be given b64 or gzip or (gz+b64).
# The content will be decoded accordingly and then written to the path that is
# provided.
#
# Note: Content strings here are truncated for example purposes.
# ssh_pwauth: True
# chpasswd:
#   list: |
#      root:linux
#   expire: False



# cloud-config
 
# Hostname management
preserve_hostname: False
manage_etc_hosts: true
hostname: ${hostname}
fqdn: ${hostname}.localdomain
 
# Users
disable_root: true
ssh_pwauth: no

users:
    - default
    - name: devops
      groups: ['wheel']
      shell: /bin/bash
      sudo: ALL=(ALL) NOPASSWD:ALL
      ssh-authorized-keys:
        - ${auth_key} 

# Configure where output will go
output:
  all: ">> /var/log/cloud-init.log"
 
# configure interaction with ssh server
ssh_genkeytypes: ['ed25519', 'rsa']
 
# Install my public ssh key to the first user-defined user configured
# in cloud.cfg in the template (which is centos for CentOS cloud images)
ssh_authorized_keys:
  - ${auth_key} 

# set timezone for VM
timezone: Etc/UTC

# Remove cloud-init 
runcmd:
  - systemctl stop network && systemctl start network
  - yum -y remove cloud-init
