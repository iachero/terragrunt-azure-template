# ---------------------------------------------------------------------------------------------------------------------
# VARIÁVEIS DE AMBIENTE PARA DESENVOLVIMENTO
# Este arquivo contém todas as variáveis específicas do ambiente de desenvolvimento
# ---------------------------------------------------------------------------------------------------------------------

locals {

  # Variáveis de ambiente
  environment = "dev"
  location    = "eastus2" # Região principal do Azure para este ambiente

  # Tags comuns para todos os recursos neste ambiente
  common_tags = {
    Environment = "Development"
    ManagedBy   = "Terragrunt"
    Project     = "MeuProjeto"
    CostCenter  = "DevOps-123"
    Owner       = "time-devops@minhaempresa.com"
  }
}
