## 🔐 Variáveis de Autenticação 

### 🔑 Service Principal

```bash
export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
export ARM_CLIENT_SECRET="sua-client-secret"
export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
```

### 🔑 Managed Identity

```bash
export ARM_USE_MSI=true
export ARM_MSI_ENDPOINT="http://169.254.169.254/metadata/identity/oauth2/token"
```

### AWS

```bash
export AWS_ACCESS_KEY_ID="AKIAXXXXXXXXXXXXXXXX"
export AWS_SECRET_ACCESS_KEY="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
export AWS_REGION="us-east-1"
export AWS_PROFILE="meu-perfil"
```

### GCP

```bash
export GOOGLE_APPLICATION_CREDENTIALS="/caminho/para/arquivo-credenciais.json"
export GOOGLE_PROJECT="meu-projeto-gcp"
export GOOGLE_REGION="us-central1"
export GOOGLE_ZONE="us-central1-a"
```

### 🛠️ Configuração Terragrunt

```bash
# Variável para definir ambiente (dev, qa, prod)
export ENV="dev"

# Variáveis para backends personalizados
export TG_BUCKET_NAME="meu-bucket-terraform-state"
export TG_DYNAMODB_TABLE="terraform-locks"
export TG_CONTAINER_NAME="tfstate"
export TG_STORAGE_ACCOUNT="tfstatestorageaccount"

# Controle de log
export TG_LOG_LEVEL="info"  # debug, info, warn, error
export TG_NON_INTERACTIVE="true"  # Desativar prompts interativos

# Configurações experimentais
export TG_EXPERIMENT_MODE="true"
export TG_EXPERIMENT="auto-init,providers-lock"
```

### 📁 Gerenciamento de Estado Terraform

```bash
# Backend Type
TF_BACKEND_TYPE="azurerm"  # azurerm, s3, gcs, etc.

# Azure Backend
TF_RESOURCE_GROUP_NAME="rg-terraform-state"
TF_STORAGE_ACCOUNT_NAME="tfstate20240101"
TF_CONTAINER_NAME="tfstate"
TF_STATE_KEY="${path_relative_to_include()}/terraform.tfstate"

# AWS Backend
TF_S3_BUCKET="terraform-state-bucket"
TF_DYNAMODB_TABLE="terraform-locks"
TF_STATE_REGION="us-east-1"
TF_STATE_KEY="${path_relative_to_include()}/terraform.tfstate"

# GCP Backend
TF_GCS_BUCKET="terraform-state-bucket"
TF_GCS_PREFIX="${path_relative_to_include()}"
```

🔄 Variáveis Locais Convenientes

```bash


```hcl
locals {
  # Identificação do ambiente
  environment       = local.env_vars.locals.environment  # "dev", "qa", "prod"
  location          = local.env_vars.locals.location     # "eastus2", "westeurope", etc.
  location_short    = local.env_vars.locals.location_short  # "eu2", "weu", etc.
  
  # Prefixos para nomeação
  prefix            = "${local.environment}-${local.location_short}"
  resource_prefix   = "myproject-${local.prefix}"
  
  # Tags comuns
  common_tags = {
    Environment     = local.environment
    Project         = "MyProject"
    Owner           = "DevOps Team"
    ManagedBy       = "Terragrunt"
    CostCenter      = "CC-123456"
    TerraformModule = path_relative_to_include()
  }
  
  # Configurações de rede
  address_space     = local.env_vars.locals.address_space
  subnets           = local.env_vars.locals.subnets
  
  # Controle de recursos
  instance_count    = local.env_vars.locals.instance_count
  instance_size     = local.env_vars.locals.instance_size
  
  # Caminhos úteis
  root_dir          = get_repo_root()
  relative_path     = path_relative_to_include()
  module_name       = basename(get_terragrunt_dir())
}
```

🏷️ Padrões de Tags

```hcl
locals {
  # Tags básicas
  base_tags = {
    Environment    = local.environment
    Project        = "MyProject"
    Owner          = "team@example.com"
    ManagedBy      = "Terragrunt"
  }
  
  # Tags para compliance
  compliance_tags = {
    Classification = "restricted"
    Compliance     = "PCI-DSS,GDPR"
    DataRetention  = "1-year"
  }
  
  # Tags para operações
  operational_tags = {
    BackupPolicy   = "daily"
    PatchGroup     = "weekly"
    Criticality    = "high"
  }
  
  # Tags para custos
  cost_tags = {
    CostCenter     = "IT-12345"
    BusinessUnit   = "Finance"
    ChargeBack     = "true"
  }
  
  # Combine todas as tags conforme necessário
  all_tags = merge(
    local.base_tags,
    local.compliance_tags,
    local.operational_tags,
    local.cost_tags,
    {
      Name = "${local.resource_prefix}-${local.module_name}"
    }
  )
}
```

🔢 Convenções de Nomenclatura

```hcl
locals {
  # Funções de nomenclatura
  naming = {
    # Padrão geral: {tipo}-{projeto}-{ambiente}-{região}-{instância}
    resource_group        = "rg-${local.resource_prefix}-${local.module_name}"
    virtual_network       = "vnet-${local.resource_prefix}-${local.module_name}"
    subnet                = "snet-${local.resource_prefix}-${local.module_name}"
    network_interface     = "nic-${local.resource_prefix}-${local.module_name}"
    public_ip             = "pip-${local.resource_prefix}-${local.module_name}"
    network_security_group = "nsg-${local.resource_prefix}-${local.module_name}"
    storage_account       = "st${local.environment}${local.location_short}${replace(local.module_name, "-", "")}${random_string.suffix.result}"
    key_vault             = "kv-${local.resource_prefix}-${local.module_name}"
    container_registry    = "cr${local.environment}${local.location_short}${replace(local.module_name, "-", "")}"
    kubernetes_cluster    = "aks-${local.resource_prefix}-${local.module_name}"
    sql_server            = "sql-${local.resource_prefix}-${local.module_name}"
    cosmos_db             = "cosmos-${local.resource_prefix}-${local.module_name}"
    function_app          = "func-${local.resource_prefix}-${local.module_name}"
    app_service           = "app-${local.resource_prefix}-${local.module_name}"
    app_service_plan      = "asp-${local.resource_prefix}-${local.module_name}"
  }
}
```

📊 Variáveis para Backends

```hcl
locals {
  # Azure Backend
  az_backend = {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sttfstate${local.environment}"
    container_name       = "tfstate"
    key                  = "${local.relative_path}/terraform.tfstate"
  }
  
  # AWS Backend  
  aws_backend = {
    bucket         = "tfstate-${local.account_id}-${local.region}"
    key            = "${local.relative_path}/terraform.tfstate"
    region         = local.region
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
  
  # GCP Backend
  gcp_backend = {
    bucket      = "tfstate-${local.project_id}"
    prefix      = local.relative_path
  }
}
```

📚 Dicas de Uso


- Armazene variáveis específicas do ambiente em arquivos env_${local.environment}.hcl
- Use variáveis de ambiente para valores sensíveis como credenciais
- Defina convenções de nomenclatura em um arquivo central
- Aplique tags consistentes em todos os recursos para facilitar o gerenciamento e a alocação de custos
- Organize seus módulos em uma estrutura de diretórios que reflita a organização lógica dos recursos
- Use locais como intermediários para calcular outros valores


🔗 Funções Auxiliares Úteis do Terragrunt

```bash
# Obter diretório atual
current_dir = get_terragrunt_dir()

# Obter caminho relativo ao arquivo de inclusão
relative_path = path_relative_to_include()

# Obter raiz do repositório
repo_root = get_repo_root()

# Obter uma variável de ambiente ou valor padrão
env_var = get_env("ENV", "dev")

# Ler inputs de outro módulo
inputs_from_module = read_terragrunt_config("../other/module/terragrunt.hcl").inputs

# Gerando lista de dependências
dependency_paths = [
  "../vpc",
  "../security-groups",
  "../database"
]
```

