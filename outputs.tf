output "client_id" {
  value = azuread_application.this.client_id
}

output "client_secret" {
  value = nonsensitive(azuread_application_password.this.value)
}

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