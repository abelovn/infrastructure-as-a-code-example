data "yandex_compute_image" family_images_pdc {
  family = var.family_images_pdc
}

data "template_file" "userdata_win" {
  template = file("user_data.tmpl")
  vars = {
    windows_password = var.windows_password
  }
}

resource "yandex_compute_instance" "active_directory" {

  name        = "active-directory"
  platform_id = "standard-v3"
  hostname    = var.hostname

  resources {
    cores  = var.cores
    memory = var.memory
  }

  boot_disk {
    initialize_params {
      size     = var.disk_size
      type     = var.disk_type
      image_id = data.yandex_compute_image.family_images_pdc.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    user-data          = data.template_file.userdata_win.rendered
    serial-port-enable = 1
  }

  provisioner "remote-exec" {
    connection {
      type     = "winrm"
      user     = "Administrator"
      host     = self.network_interface.0.nat_ip_address
      password = var.windows_password
      https    = true
      port     = 5986
      insecure = true
      timeout  = "15m"
    }

    inline = [
      "echo hello",
      "powershell.exe Write-Host hello",
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
  value       = yandex_compute_instance.active_directory.network_interface.0.nat_ip_address
}

resource "local_file" "host_ini" {
  content  = data.template_file.host_ini.rendered
  filename = "host.ini"
}

data "template_file" "host_ini" {
  template = file("host_ini.tmpl")
  vars = {
    windows_password = var.windows_password
    hostname         = var.hostname
    pdc_domain       = var.pdc_domain
    pdc_domain_path  = var.pdc_domain_path
    public_ip        = yandex_compute_instance.active_directory.network_interface.0.nat_ip_address
  }
}

resource "local_file" "inventory_yml" {
  content  = data.template_file.inventory_yml.rendered
  filename = "inventory.yml"
}

data "template_file" "inventory_yml" {
  template = file("inventory_yml.tmpl")
  vars = {
    windows_password = var.windows_password
    hostname         = var.hostname
    pdc_domain       = var.pdc_domain
    pdc_domain_path  = var.pdc_domain_path
    public_ip        = yandex_compute_instance.active_directory.network_interface.0.nat_ip_address
  }
}


