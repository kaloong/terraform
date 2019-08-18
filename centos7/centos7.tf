provider "vsphere" {
  user           = "${var.vsphere_user}"
  password       = "${var.vsphere_password}"
  vsphere_server = "${var.vsphere_vcenter}"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "${var.vsphere_datacenter}"
}

data "vsphere_virtual_machine" "template" {
  name = "centos7"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name = "DPortGroup21"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_datastore_cluster" "datastore" {
  name = "DS_Cluster_01"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
  name = "Terraform_RP"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "centos7vm01" {
  name     = "centos7vm01"
  num_cpus = 1
  memory   = 1024
  network_interface {  
    network_id = "${data.vsphere_network.network.id}"
  }
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  guest_id         = "centos7_64Guest"
  clone {
    template_uuid  = "${data.vsphere_virtual_machine.template.id}"
    customize {
      dns_server_list = ["172.16.30.100","172.16.30.101"]

      linux_options {
        host_name = "centos7vm01"
        domain    = "mihome.lab"
      }
      network_interface {
        ipv4_address = "172.16.21.60"
        ipv4_netmask = "24"
      }
      ipv4_gateway = "172.16.21.10"
      timeout      = "20"
    }
  }
  datastore_cluster_id = "${data.vsphere_datastore_cluster.datastore.id}"
  disk {
    label = "centos7_vm01.vmdk"
    size  = 20
    thin_provisioned = "false"
  }
}
