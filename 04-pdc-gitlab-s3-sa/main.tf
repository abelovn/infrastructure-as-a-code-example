data "yandex_compute_image" family_images_windows {
  family = var.family_images_windows
}

data "yandex_compute_image" family_images_linux {
  family = var.family_images_linux
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
  hostname    = var.pdc_hostname
  service_account_id = yandex_iam_service_account.sa-compute-admin.id

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      size     = 60
      type     = "network-ssd"
      image_id = data.yandex_compute_image.family_images_windows.id
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

resource "yandex_compute_instance" "gitlab" {

  name        = "gitlab"
  platform_id = "standard-v3"
  hostname    = var.gitlab_hostname
  service_account_id = yandex_iam_service_account.sa-compute-admin.id

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      size     = 40
      type     = "network-ssd"
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
output "public_ip_pdc" {
  description = "Public IP address for active directory"
  value       = yandex_compute_instance.active_directory.network_interface.0.nat_ip_address
}

output "public_ip_gitlab" {
  description = "Public IP address for gitlab"
  value       = yandex_compute_instance.gitlab.network_interface.0.nat_ip_address
}

resource "local_file" "host_ini" {
  content  = data.template_file.host_ini.rendered
  filename = "host.ini"
}

data "template_file" "host_ini" {
  template = file("host_ini.tmpl")
  vars = {
    windows_password      = var.windows_password
    pdc_hostname          = var.pdc_hostname
    pdc_domain            = var.pdc_domain
    pdc_domain_path       = var.pdc_domain_path
    public_ip_pdc         = yandex_compute_instance.active_directory.network_interface.0.nat_ip_address
    gitlab_hostname       = var.gitlab_hostname
    public_ip_gitlab      = yandex_compute_instance.gitlab.network_interface.0.nat_ip_address
    letsencrypt_domain    = var.letsencrypt_domain
    pswd_gitlab_ldap_sync = var.pswd_gitlab_ldap_sync
    pswd_test_user_in_pdc = var.pswd_test_user_in_pdc
    aws_access_key_id     = yandex_storage_bucket.gitlab-backup-anton-patsev.access_key
    aws_secret_access_key = yandex_storage_bucket.gitlab-backup-anton-patsev.secret_key
    gitlab_backup_bucket_name = "gitlab-backup-anton-patsev"
    
  }
}

resource "local_file" "inventory_yml" {
  content  = data.template_file.inventory_yml.rendered
  filename = "inventory.yml"
}

data "template_file" "inventory_yml" {
  template = file("inventory_yml.tmpl")
  vars = {
    windows_password      = var.windows_password
    pdc_hostname          = var.pdc_hostname
    pdc_domain            = var.pdc_domain
    pdc_domain_path       = var.pdc_domain_path
    public_ip_pdc         = yandex_compute_instance.active_directory.network_interface.0.nat_ip_address
    gitlab_hostname       = var.gitlab_hostname
    public_ip_gitlab      = yandex_compute_instance.gitlab.network_interface.0.nat_ip_address
    letsencrypt_domain    = var.letsencrypt_domain
    pswd_gitlab_ldap_sync = var.pswd_gitlab_ldap_sync
    pswd_test_user_in_pdc = var.pswd_test_user_in_pdc
    aws_access_key_id     = yandex_storage_bucket.gitlab-backup-anton-patsev.access_key
    aws_secret_access_key = yandex_storage_bucket.gitlab-backup-anton-patsev.secret_key
    gitlab_backup_bucket_name = "gitlab-backup-anton-patsev"
    
  }
}


