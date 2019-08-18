provider "vsphere" {
  user           = "${var.vsphere_user}"
  password       = "${var.vsphere_password}"
  vsphere_server = "${var.vsphere_server}"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "MihomeDC"
}

data "vsphere_datastore_cluster" "datastore" {
  name = "DatastoreCluster"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_datastore" "datastore" {
  name          = "${var.vm_datastore}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
  name		= "${var.vm_resource_pool}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name          = "${var.vm_network}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template" {
  name          = "${var.vm_template}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

#=========================#
# vSphere virtual machine #
#=========================#

variable "vm_datastore" {
  description = "ESK00_SSD_250G"
}

variable "vm_resource_pool" {
  description = "ESK00_RP"
}

variable "vm_network" {
  description = "DPortGroup21"
}

variable "vm_template" {
  description = "VM_0017"
}

variable "vm_linked_clone" {
  description = "false"
  default = "false"
}

variable "vm_ip" {
  description = "172.16.21.234"
}

variable "vm_netmask" {
  description = "24"
}

variable "vm_gateway" {
  description = "172.16.21.1"
}

variable "vm_dns" {
  description = "172.16.30.101"
}

variable "vm_domain" {
  description = "mihome.lab"
}

variable "vm_cpu" {
  description = "1"
}

variable "vm_ram" {
  description = "1024"
}

variable "vm_name" {
  description = "terraform-testvm"
}


resource "vsphere_virtual_machine" "vm" {
  name             = "${var.vm_name}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_cluster_id    = "${data.vsphere_datastore_cluster.datastore.id}"

  num_cpus = 1
  memory   = 1024
  guest_id = "other3xLinux64Guest"

  network_interface {
    network_id = "${data.vsphere_network.network.id}"
  }

  disk {
    label = "${var.vm_name}.vmdk"
    size  = 20
    thin_provisioned = true
  }
  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"
    linked_clone  = "${var.vm_linked_clone}"

    customize {
      timeout = "20"

      linux_options {
        host_name = "${var.vm_name}"
        domain    = "${var.vm_domain}"
      }

      network_interface {
        ipv4_address = "${var.vm_ip}"
        ipv4_netmask = "${var.vm_netmask}"
      }

      ipv4_gateway    = "${var.vm_gateway}"
      dns_server_list = ["${var.vm_dns}"]
    }
  }
}

