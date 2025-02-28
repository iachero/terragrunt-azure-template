# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt é um wrapper para Terraform que fornece ferramentas adicionais para trabalhar com múltiplos módulos,
# estado remoto e bloqueio: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Carrega automaticamente as variáveis de nível de ambiente
  env_vars = read_terragrunt_config(find_in_parent_folders("env_${get_env("ENV", "dev")}.hcl"))

  # Extrai as variáveis necessárias para fácil acesso
  subscription_id = get_env("ARM_SUBSCRIPTION_ID")
  client_id       = get_env("ARM_CLIENT_ID")
  client_secret   = get_env("ARM_CLIENT_SECRET")
  tenant_id       = get_env("ARM_TENANT_ID")
  environment     = local.env_vars.locals.environment
  location        = local.env_vars.locals.location

  # Configurações para armazenamento de estado
  deployment_storage_resource_group_name = "rg-terragrunt-state"
  deployment_storage_account_name        = "stterragruntstate21766"
  deployment_storage_container_name      = "tg-tfstate"
}

# Gera um bloco de provider Azure
generate "provider" {
  path      = "providers.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "azurerm" {
  features {}
  subscription_id = "${local.subscription_id}"
  client_id       = "${local.client_id}"
  client_secret   = "${local.client_secret}"
  tenant_id       = "${local.tenant_id}"
}
EOF
}

# Configura o Terragrunt para armazenar automaticamente os arquivos tfstate em um container de Blob Storage
remote_state {
  backend = "azurerm"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    subscription_id      = local.subscription_id
    resource_group_name  = local.deployment_storage_resource_group_name
    storage_account_name = local.deployment_storage_account_name
    container_name       = local.deployment_storage_container_name
    key                  = "${path_relative_to_include()}/terraform.tfstate"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# PARÂMETROS GLOBAIS
# Essas variáveis se aplicam a todas as configurações nesta subpasta. Elas são automaticamente mescladas na configuração
# filha `terragrunt.hcl` através do bloco include.
# ---------------------------------------------------------------------------------------------------------------------

# Configura variáveis de nível raiz que todos os recursos podem herdar. Isso é especialmente útil com configurações
# multi-conta onde as fontes de dados terraform_remote_state são colocadas diretamente nos módulos.
inputs = merge(
  local.env_vars.locals,
  {
    client_secret = local.client_secret
  }
)


terraform {
  # Força o Terraform a continuar tentando adquirir um bloqueio por
  # até 20 minutos se outra pessoa já tiver o bloqueio
  extra_arguments "retry_lock" {
    commands = get_terraform_commands_that_need_locking()

    arguments = [
      "-lock-timeout=20m"
    ]
  }
  before_hook "delete_cache" {
    commands = [get_terraform_command()]
    execute  = ["find", ".", "-type", "d", "-name", ".terragrunt-cache", "-exec", "rm", "-rf", "{}", ";"]
  }

  before_hook "before_cache" {
    commands = [get_terraform_command()]
    execute  = ["mkdir", "-p", "/tmp/.terragrunt-cache/.plugins"]
  }
  extra_arguments "terragrunt_plugins" {
    commands = [get_terraform_command()]
    env_vars = {
      TF_PLUGIN_CACHE_DIR = "/tmp/.terragrunt-cache/.plugins"
    }
  }
}
download_dir = "/tmp/.terragrunt-cache"
