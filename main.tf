# Data Source: Azure Subscription
data "azurerm_subscription" "this" {}

# Data Source: Principal ID of the current user
data "azuread_client_config" "this" {}

# Data Source: Azure Resource Group
data "azurerm_resource_group" "this" {
  name = var.resource_group
}

# Data Source: Azure Virtual Network
data "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.this.name
}

# Data Source: Azure Virtual Network Subnet
data "azurerm_subnet" "this" {
  name                 = var.subnet_name
  resource_group_name  = data.azurerm_resource_group.this.name
  virtual_network_name = data.azurerm_virtual_network.this.name
}

#@@@ Create an App Registration and Service Principal for Azure DevOps

resource "azuread_application" "this" {
  display_name = var.service_connection_name
}

resource "azuread_service_principal" "this" {
  application_id = azuread_application.this.application_id
}

#@@@ Create a client secret for the App Registration. No foreseeable expiration

resource "azuread_application_password" "this" {
  end_date              = "2299-12-30T23:00:00Z"
  application_object_id = azuread_application.this.object_id
}

#@@@ Assign 'Contributor' role for the Service Principal in the Azure Subscription

resource "azurerm_role_assignment" "this" {
  scope                = data.azurerm_subscription.this.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.this.object_id
}

#@@@ Create an Azure Compute Gallery

resource "azurerm_shared_image_gallery" "this" {
  name                = var.compute_gallery_name
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location
  description         = "Azure Compute Gallery"
}

#@@@ Create an image definition in the Azure Compute Gallery

resource "azurerm_shared_image" "this" {
  name                = var.image_name
  gallery_name        = azurerm_shared_image_gallery.this.name
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location
  os_type             = "Linux"
  hyper_v_generation  = "V2"

  identifier {
    publisher = "cloudmethods"
    offer     = var.image_name
    sku       = var.image_name
  }
}

#@@@ Create an Azure Image using Packer and push to the compute gallery

resource "null_resource" "packer" {
  provisioner "local-exec" {
    command = "export ARM_SUBSCRIPTION_ID="$(az account list --query `"[?isDefault].id`" --output tsv)"
  }
  provisioner "local-exec" {
    working_dir = "../"
    command     = <<EOF
      packer build -force \
        -var client_id=${azuread_application.this.application_id} \
        -var client_secret=${azuread_application_password.this.value} \
        -var subscription_id=${ARM_SUBSCRIPTION_ID} \
        -var label=${var.label} \
        -var resource_group=${var.resource_group} \
        -var vnet_name=${var.vnet_name} \
        -var subnet_name=${var.subnet_name} \
        -var compute_gallery_name=${var.compute_gallery_name} \
        -var image_name=${var.image_name} \
        packer/azure-methods-devops.pkr.hcl
    EOF
  }

  depends_on = [
    azurerm_role_assignment.this
  ]
}

#@@@ Create a Virtual Machine Scale Set (VMSS)

resource "azurerm_linux_virtual_machine_scale_set" "this" {
  name                            = var.vmss_name
  resource_group_name             = data.azurerm_resource_group.this.name
  location                        = data.azurerm_resource_group.this.location
  sku                             = "Standard_B2s"
  instances                       = 0
  disable_password_authentication = false
  admin_username                  = "devops"
  admin_password                  = "Dev0ps123!"
  source_image_id                 = "${azurerm_shared_image.this.id}/versions/latest"

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "nic0"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = data.azurerm_subnet.this.id
    }
  }

  depends_on = [
    null_resource.packer
  ]
}