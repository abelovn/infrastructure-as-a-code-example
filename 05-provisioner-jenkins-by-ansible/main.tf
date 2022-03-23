data "yandex_compute_image" family_images_linux {
  family = var.family_images_linux
}

resource "yandex_compute_instance" "jenkins" {

  name        = "jenkins"
  platform_id = "standard-v3"
  hostname    = var.hostname
  service_account_id = yandex_iam_service_account.sa-compute-admin.id

  resources {
    cores  = var.cores
    memory = var.memory
  }

  boot_disk {
    initialize_params {
      size     = var.disk_size
      type     = var.disk_type
      image_id = data.yandex_compute_image.family_images_linux.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.network_interface.0.nat_ip_address
      private_key = file("~/.ssh/id_rsa")
    }

    inline = [
      "echo hello"
    ]
  }

}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

# Output values
output "public_ip" {
  description = "Public IP address for active directory"
  value       = yandex_compute_instance.jenkins.network_interface.0.nat_ip_address
}

resource "local_file" "host_ini" {
  content  = data.template_file.host_ini.rendered
  filename = "host.ini"
}

data "template_file" "host_ini" {
  template = file("host_ini.tmpl")
  vars = {
    hostname            = var.hostname
    public_ip           = yandex_compute_instance.jenkins.network_interface.0.nat_ip_address
    domain              = var.domain
  }
}

resource "local_file" "inventory_yml" {
  content  = data.template_file.inventory_yml.rendered
  filename = "inventory.yml"
}

data "template_file" "inventory_yml" {
  template = file("inventory_yml.tmpl")
  vars = {
    hostname            = var.hostname
    public_ip           = yandex_compute_instance.jenkins.network_interface.0.nat_ip_address
    domain              = var.domain
  }
}
