variable "label" {
  type        = string
  description = "A description of the target environment platform"
  default     = "sample"
}

## Azure connection details

variable "tenant_id" {
  type        = string
  description = "Azure AD directory/tenant ID"
}

variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID"
}

## Azure resource details

variable "service_connection_name" {
  type        = string
  description = "Name of the application registration"
  default     = "azure-devops-service-connection"
}

variable "resource_group" {
  type        = string
  description = "Name of the resource group for resource deployment"
  default     = "rg-shared-services"
}

variable "vnet_name" {
  type        = string
  description = "Name of the virtual network"
}

variable "subnet_name" {
  type        = string
  description = "Name of the virtual network subnet"
}

variable "compute_gallery_name" {
  type        = string
  description = "Name of the Azure Compute Gallery"
  default     = "galcloudmethods"
}

variable "vmss_name" {
  type        = string
  description = "Name of the Virtual Machine Scale Set"
  default     = "vmss-devops-agents"
}

variable "image_name" {
  type        = string
  description = "Name of image"
  default     = "devops-agent"
}