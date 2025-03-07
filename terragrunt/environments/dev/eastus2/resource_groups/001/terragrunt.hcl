# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Configuração para criação de um Resource Group usando o módulo terraform-azurerm-rg-module
# ---------------------------------------------------------------------------------------------------------------------

include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "git@ssh.dev.azure.com:v3/Sinqia/Terraform/terraform-azurerm-rg-module"
}

# ---------------------------------------------------------------------------------------------------------------------
# PARÂMETROS ESPECÍFICOS PARA ESTE MÓDULO
# ---------------------------------------------------------------------------------------------------------------------

inputs = {
  # Nome do resource group - usando convenção de nomenclatura
  resource_group_name = "rg-template-tg-${local.environment}-${local.location}-001"
  location            = local.location

  # Tags a serem aplicadas ao resource group
  tags = merge(
    local.common_tags,
    # {
    #   Name        = "rg-${local.environment}-${local.location_short}-001"
    #   Description = "Resource Group para recursos de aplicação"
    # }
  )
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
