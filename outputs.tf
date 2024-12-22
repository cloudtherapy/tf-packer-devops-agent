output "client_id" {
  value = azuread_application.this.application_id
}

output "client_secret" {
  value = nonsensitive(azuread_application_password.this.value)
}

output "subscription_id" {
  value = var.subscription_id
}

output "label" {
  value = var.label
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