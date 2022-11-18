#!/bin/bash

# vars
basedir=$(dirname $0)
hosts_file="$basedir/../ansible/inventory/hosts"

sp="/-\|"
sc=0
spin() {
   printf "\b${sp:sc++:1}"
   ((sc==${#sp})) && sc=0
}

echo "github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=" > /home/fmungari/.ssh/known_hosts

ip_aval=1
echo "Wait for the IPs to become available..."
while [[ $ip_aval -ne 0 ]]; do
    if [[ $(sudo virsh net-dhcp-leases default | wc -l) -lt 6 ]]; then
        spin
    else
        ip_aval=0
    fi
done
echo "[master]" > $hosts_file
echo "[worker]" >> $hosts_file
for instance in $(sudo virsh list --all | grep k8s | awk {'print $2'} | sort); do
    host=$(sudo virsh domifaddr $instance | grep -ohe "192.*" | cut -d"/" -f1)
    case $instance in
        *"master"*)        
            sed -i "/^\[master\]/a $instance ansible_host=$host" $hosts_file
            ;;
        *"worker"*)
            sed -i "/^\[worker\]/a $instance ansible_host=$host" $hosts_file
            ;;
    esac
done