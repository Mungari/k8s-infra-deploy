terraform {
  required_providers {
    cloudinit = {
      source = "hashicorp/cloudinit"
      version = "2.2.0"
    }
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.7.0"
    }
  }
}

provider "libvirt" {
  # Configuration options
  # Configure kvm host
  uri = "qemu:///system" #Quemu host
}

# Create disk that contains image
resource "libvirt_volume" "centos"{ 
    name = "centos"
    pool = "default"
    #source = "https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2" # Cloud image
    source = "/home/fmungari/images/centos-7.qcow2" # Locally saved image
    #format = "qcow2"
}

resource "libvirt_volume" "test" {
  for_each = var.k8s-nodes
  name = each.value.disk
  base_volume_id = libvirt_volume.centos.id
}

data "template_file" "user_data" {
  template = "${file("${path.module}/configs/users_and_groups.cfg")}"
}

resource "libvirt_cloudinit_disk" "commoninit" {
  for_each = var.k8s-nodes

  name = format("%s%s",each.key,"commoninit.iso")
  pool = "default"
  user_data  = "${data.template_file.user_data.rendered}"
}

resource "libvirt_domain" "k8s-nodes"{
    for_each = var.k8s-nodes
    name = each.key
    memory = "2048"
    vcpu = "2" # Consider upping to 2
    network_interface {
        network_name = "default" # List networks with virsh net-list
        addresses = [each.value.ip]
    }
    disk {
        volume_id = "${libvirt_volume.test[each.value.disk].id}"
    }
    cloudinit = "${libvirt_cloudinit_disk.commoninit[each.key].id}"
    console {
        type = "pty"
        target_type = "serial"
        target_port = "0"
    }
}
