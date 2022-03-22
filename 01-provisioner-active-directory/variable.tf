variable "yc_token" {
  type        = string
  description = "Yandex Cloud API key"
}

variable "yc_cloud_id" {
  type        = string
  description = "Yandex Cloud id"
}

variable "yc_folder_id" {
  type        = string
  description = "Yandex Cloud folder id"
}

variable "yc_zone" {
  type        = string
  description = "Yandex Cloud compute default zone"
  default     = "ru-central1-c"
}

variable "family_images_pdc" {
  type        = string
  description = "Family of images pdc in Yandex Cloud. Example: windows-2022-dc-gvlk, windows-2019-dc-gvlk"
}

variable "windows_password" {
  type        = string
  description = "Password for Windows"
}

variable "hostname" {
  type        = string
  description = "hostname"
}

variable "pdc_domain" {
  type        = string
  description = "pdc_domain. Example: domain.test"
}

variable "pdc_domain_path" {
  type        = string
  description = "pdc_domain_path. Example: dc=domain,dc=test"
}
