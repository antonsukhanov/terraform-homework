variable "folder_id" {
  type = string
}

variable "availability_zone" {
  type = string
}

variable "network_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "ci_image_id" {
  type = string
}

variable "mdb_db" {
  type = string
}

variable "mdb_user" {
  type = string
  sensitive = true
}

variable "mdb_password" {
  type = string
  sensitive = true
}
