terraform {
  # Версия terraform
  required_version = "0.12.19"
}

provider "google" {
  # Версия провайдера
  version = "2.15"
  region  = var.region
  zone    = var.zone
  # ID проекта
  project = var.project
}

# Добавление ssh-ключей в метаданные проекта для нескольких пользователей с сохранением! существующих ssh-ключей
resource "google_compute_project_metadata_item" "ssh-keys-ry" {
  key   = "sshKeys"
  value = "ry:${file(var.public_key_path)} \nuser2:${file(var.public_key_path)}"
}

resource "google_compute_instance" "gitlab-ci" {
  name         = "gitlab-ci"
  machine_type = "n1-standard-1"
  tags         = ["gitlab-ci","http-server","https-server"]
  metadata = {
    # добавление ssh-ключей в метаданные инстанса для нескольких пользователей
    ssh-keys = "user0:${file(var.public_key_path)}\nuser1:${file(var.public_key_path)}"
  }


  boot_disk {
    initialize_params {
      image = var.disk_image
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  connection {
    type  = "ssh"
    host  = self.network_interface[0].access_config[0].nat_ip
    user  = "ry"
    agent = false
    # путь до приватного ключа
    private_key = file(var.private_key_path)
  }

  #  provisioner "file" {
  #    source      = "files/puma.service"
  #    destination = "/tmp/puma.service"
  #  }
  #
  #provisioner "remote-exec" {
  #script = "files/deploy.sh"
  #}
}

#resource "google_compute_firewall" "firewall_puma" {
#  name = "allow-puma-default"
#  # Название сети, в которой действует правило
#  network = "default"
#  # Какой доступ разрешить
#  allow {
#    protocol = "tcp"
#    ports    = ["9292"]
#  }
#  # Каким адресам разрешаем доступ
#  source_ranges = ["0.0.0.0/0"]
#  # Правило применимо для инстансов с перечисленными тэгами
#  target_tags = ["reddit-app"]
#}
