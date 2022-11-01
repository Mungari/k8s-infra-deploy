#!/bin/bash

# vars
basedir=$(dirname $0)
hosts_file="$basedir/ansible/inventory/hosts"

sp="/-\|"
sc=0
spin() {
   printf "\b${sp:sc++:1}"
   ((sc==${#sp})) && sc=0
}

ip_aval=1
echo "Wait for the IPs to become available..."
while [[ $ip_aval -ne 0 ]]; do
    if [[ $(sudo virsh net-dhcp-leases default | wc -l) -le 3 ]]; then
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