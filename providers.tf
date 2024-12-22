terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.14.0"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = "3.0.2"
    }
  }
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "cloudtherapy"

    workspaces {
      name = "tf-packer-devops-agent"
    }
  }
}

# Azure Active Directory provider
# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs
provider "azuread" {

}

# Azure Resource Manager provider
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}