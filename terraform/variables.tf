variable project {
  description = "Project ID"
}
variable region {
  description = "Region"
  # Значение по умолчанию
  default = "us-central1"
}
variable zone {
  description = "Zone"
  # Значение по умолчанию
  default = "us-central1-a"
}
variable public_key_path {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}
variable disk_image {
  description = "Disk image"
  # Значение по умолчанию
  default = "ubuntu-1604-lts"
}
variable private_key_path {
  # Описание переменной
  description = "Path to the private key used for ssh access"
}
