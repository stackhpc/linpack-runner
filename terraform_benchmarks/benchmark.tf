variable "hpl_image" {
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
}

provider "openstack" {
  # use environment variables
}

resource "openstack_compute_instance_v2" "compute" {
  name            = "benchmark-compute-${count.index}"
  image_name      = var.hpl_image
  flavor_name     = var.flavor
  key_pair        = var.key
  security_groups = ["default"]
  count           = 7
  availability_zone = "nova::${split(",", var.compute_hosts)[count.index]}"
  network {
    uuid = var.network
  }
}

resource "openstack_compute_floatingip_associate_v2" "myip" {
   count = var.floating_ip != null ? 1 : 0
   floating_ip = var.floating_ip
   instance_id = openstack_compute_instance_v2.compute.0.id
   fixed_ip    = openstack_compute_instance_v2.compute.0.network.0.fixed_ip_v4
}

data  "template_file" "inventory" {
    template = "${file("./templates/inventory.tpl")}"
    vars = {
      computes = <<EOT
%{for compute in openstack_compute_instance_v2.compute}
${compute.name} ansible_host=%{if length(compute.network) != 0}${compute.network[0].fixed_ip_v4}%{ endif } ansible_user=${var.login_user}%{ endfor }
EOT
    }
}

resource "local_file" "hosts" {
  content  = data.template_file.inventory.rendered
  filename = "inventory"
}
