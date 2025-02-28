include "root" {
  path = find_in_parent_folders("root.hcl")
}
# Variáveis locais específicas para este módulo
locals {
  # Carrega as variáveis do ambiente
  env_vars = read_terragrunt_config(find_in_parent_folders("env_${get_env("ENV", "dev")}.hcl"))
  # Extrai as variáveis necessárias
  environment = local.env_vars.locals.environment
  location    = local.env_vars.locals.location
  common_tags = local.env_vars.locals.common_tags
}

terraform {
  source = "git@ssh.dev.azure.com:v3/Sinqia/Terraform/terraform-azurerm-network-module"
}

# Dependência do Resource Group
dependency "resource_group" {
  config_path = "../../../resource_groups/001"

  # Configuração de mock para permitir planos quando o recurso não existe
  mock_outputs = {
    resource_group_name = "mock-rg-name"
    location            = "eastus2"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "hclvalidate"]
}

dependencies {
  paths = ["../../../resource_groups/001"]
}

inputs = {
  create_resource_group = false
  resource_group_name   = dependency.resource_group.outputs.resource_group_name
  location              = local.location
  vnet_name             = "vnet-template-tg-${local.environment}-${local.location}-001"
  vnet_address_space    = ["10.0.0.0/16", "192.168.0.0/16"]
  virtual_network_dns_servers = {
    # dns_servers = ["10.0.0.4", "10.0.0.5"]
  } # (Optional) Lista de endereços IP dos servidores DNS (Default: null)

  # Tags a serem aplicadas a vnet
  tags = merge(
    local.common_tags,
    # {
    #   Name        = "rg-${local.environment}-${local.location_short}-001"
    #   Description = "Resource Group para recursos de aplicação"
    # }
  )
}