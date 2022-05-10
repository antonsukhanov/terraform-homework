terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.74.0"
    }
  }
}

provider "yandex" {
  folder_id   = var.folder_id
  zone        = var.availability_zone
}

data "yandex_vpc_network" "default_network" {
  network_id = var.network_id
}

data "yandex_vpc_subnet" "default_subnet" {
  subnet_id = var.subnet_id
}

# Yandex Compute Cloud Instance creation.

resource "yandex_compute_instance" "ci-tf-homework" {
  name        = "ci-tf-homework"
  platform_id = "standard-v3" # Intel Ice Lake

  resources {
    cores  = 2
    core_fraction = 20  # 20% per vCPU
    memory = 1
  }

  boot_disk {
    initialize_params {
      image_id = var.ci_image_id
    }
  }

  network_interface {
    subnet_id = data.yandex_vpc_subnet.default_subnet.id
    nat = true
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    user-data = file("${path.module}/cloudconfig.yaml")
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

output "compute_instance_id" {
  description = "ID of the created compute instance"
  value = yandex_compute_instance.ci-tf-homework.id
}

output "compute_instance_public_ip" {
  description = "Public IP of the created compute instance"
  value = yandex_compute_instance.ci-tf-homework.network_interface.0.nat_ip_address
}

# Yandex Managed Service for PostgreSQL cluster creation.

resource "yandex_mdb_postgresql_cluster" "mdb-tf-homework" {
  name        = "mdb-tf-homework"
  environment = "PRODUCTION"
  network_id  = data.yandex_vpc_network.default_network.id

  config {
    version = 14

    resources {
      resource_preset_id = "b1.nano" # Intel Broadwell, burstable
      disk_type_id       = "network-hdd"
      disk_size          = 10
    }
  }

  maintenance_window {
    type = "WEEKLY"
    day  = "MON"
    hour = 1
  }

  database {
    name  = var.mdb_db
    owner = var.mdb_user
  }

  user {
    name       = var.mdb_user
    password   = var.mdb_password
    conn_limit = 50

    permission {
      database_name = var.mdb_db
    }
  }

  host {
    name = "master"
    assign_public_ip = true
    subnet_id = data.yandex_vpc_subnet.default_subnet.id
    zone = var.availability_zone
  }
}

output "managed_db_cluster_id" {
  description = "ID of the created managed DB instance"
  value = yandex_mdb_postgresql_cluster.mdb-tf-homework.id
}

output "managed_db_cluster_public_fqdn" {
  description = "FQDN of the created managed DB instance"
  value = yandex_mdb_postgresql_cluster.mdb-tf-homework.host[0].fqdn
}
