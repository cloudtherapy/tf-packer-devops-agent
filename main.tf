# Data Source: Azure Subscription
data "azurerm_subscription" "this" {}

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
}