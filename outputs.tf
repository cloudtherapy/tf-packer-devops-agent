output "subscription_id" {
  value = data.azurerm_subscription.this.id
}

output "resource_group" {
  value = var.resource_group
}

output "vnet_name" {
  value = var.vnet_name
}

output "subnet_name" {
  value = var.subnet_name
}