#!/bin/bash

# vars
basedir=$(dirname $0)
echo "$basedir"
hosts_file="$basedir/../ansible/inventory/hosts"
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