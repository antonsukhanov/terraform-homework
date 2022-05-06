terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.74.0"
    }
  }
}

provider "yandex" {
}

data "yandex_vpc_network" "default_network" {
  network_id = var.default_network_id
}

output "default_network_id" {
  description = "Default Network Name"
  value = data.yandex_vpc_network.default_network.name
}

data "yandex_vpc_subnet" "default_network_subnets" {
  for_each = toset(data.yandex_vpc_network.default_network.subnet_ids)
  subnet_id = each.key
}

output "default_network_subnet_names" {
  description = "Default Network Subnet Names"
  value = values(data.yandex_vpc_subnet.default_network_subnets).*.name
}

# Comment: Security groups are in the private beta in Yandex Cloud at this moment.

# data "yandex_vpc_security_group" "default_security_group" {
#   security_group_id = data.yandex_vpc_network.default_network.default_security_group_id
# }

# output "default_default_security_group_name" {
#   description = "Default Security Group Name"
#   value = data.yandex_vpc_security_group.default_security_group.name
# }
