data "yandex_compute_image" "family_images_linux" {
  family = var.family_images_linux
}

resource "yandex_compute_instance" "gitlab" {

  name               = "gitlab"
  platform_id        = "standard-v3"
  hostname           = var.gitlab_hostname
  service_account_id = yandex_iam_service_account.sa-compute-admin.id
  zone               = "ru-central1-b"

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
  name = "network-1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet-1"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

# Output values
output "public_ip" {
  description = "Public IP address for active directory"
  value       = yandex_compute_instance.gitlab.network_interface.0.nat_ip_address
}

resource "local_file" "host_ini" {
  content  = data.template_file.host_ini.rendered
  filename = "host.ini"
}

data "template_file" "host_ini" {
  template = file("host_ini.tmpl")
  vars = {
    gitlab_hostname = var.gitlab_hostname
    public_ip       = yandex_compute_instance.gitlab.network_interface.0.nat_ip_address
    domain          = var.domain
  }
}

resource "local_file" "inventory_yml" {
  content  = data.template_file.inventory_yml.rendered
  filename = "inventory.yml"
}

data "template_file" "inventory_yml" {
  template = file("inventory_yml.tmpl")
  vars = {
    gitlab_hostname = var.gitlab_hostname
    public_ip       = yandex_compute_instance.gitlab.network_interface.0.nat_ip_address
    domain          = var.domain
  }
}
