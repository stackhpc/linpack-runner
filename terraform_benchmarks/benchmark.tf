variable "benchmark_image" {
  type = string
}

variable "flavor" {
  type = string
}

variable "key" {
  type = string
}

variable "network" {
  type = string
}

variable "login_user" {
  type = string
}

variable "floating_ip" {
  type = string
}

variable "compute_hosts" {
  # list of compute hosts to use
  type = string
  default = null
}

variable "instances" {
  type = number
  default = 1
}

provider "openstack" {
  # use environment variables
}

resource "openstack_compute_instance_v2" "compute" {
  name            = "benchmark-compute-${count.index}"
  image_name      = var.benchmark_image
  flavor_name     = var.flavor
  key_pair        = var.key
  security_groups = ["default"]
  count           = var.instances
  availability_zone = var.compute_hosts != null ? "nova::${split(",", var.compute_hosts)[count.index]}" : null
  network {
    uuid = var.network
  }
}

resource "openstack_compute_floatingip_associate_v2" "myip" {
   count = var.floating_ip != null && length(openstack_compute_instance_v2.compute) != 0 && length(openstack_compute_instance_v2.compute.0.network) != 0 ? 1 : 0
   floating_ip = var.floating_ip
   instance_id = openstack_compute_instance_v2.compute.0.id
   fixed_ip    = openstack_compute_instance_v2.compute.0.network.0.fixed_ip_v4
}

resource "ansible_host" "ansible_host" {
    inventory_hostname = "benchmark-compute-${count.index}"
    groups = ["compute"]
    vars = {
        ansible_user = var.login_user
        ansible_host = length(openstack_compute_instance_v2.compute[count.index].network) >= 1 ? openstack_compute_instance_v2.compute[count.index].network[0].fixed_ip_v4 : ""
    }
    count = var.instances
}