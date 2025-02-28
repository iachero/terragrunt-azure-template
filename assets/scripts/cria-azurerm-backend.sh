#!/bin/bash

# Variáveis
RESOURCE_GROUP="rg-terragrunt-state"
STORAGE_ACCOUNT="stterragruntstate$RANDOM"
CONTAINER_NAME="tg-tfstate"
LOCATION="eastus2"
# Var tags
TAGS="Environment=Production Project=Terraform ManagedBy=IaC"

# Função para executar comandos silenciosamente
run_silent() {
  echo "Executando: $*"
  "$@" > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    echo "✅ Sucesso"
  else
    echo "❌ Erro"
    exit 1
  fi
}

# Criar Resource Group com tags
echo "Criando Resource Group..."
run_silent az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION \
  --tags $TAGS

# Criar Storage Account
echo "Criando Storage Account..."
run_silent az storage account create \
  --resource-group $RESOURCE_GROUP \
  --name $STORAGE_ACCOUNT \
  --sku Standard_LRS \
  --encryption-services blob \
  --require-infrastructure-encryption true \
  --tags $TAGS

# Criar Container
echo "Criando Container..."
run_silent az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT

# Adicionar bloqueio de recurso
echo "Adicionando bloqueio de recurso..."
run_silent az lock create \
  --name "lock-tfstate" \
  --lock-type CanNotDelete \
  --resource-group $RESOURCE_GROUP \
  --resource-name $STORAGE_ACCOUNT \
  --resource-type Microsoft.Storage/storageAccounts

# Configurar rede
# echo "Configurando rede..."
# run_silent az storage account update \
#   --resource-group $RESOURCE_GROUP \
#   --name $STORAGE_ACCOUNT \
#   --default-action Deny \
#   --bypass None

# Habilitar versionamento
echo "Habilitando versionamento..."
run_silent az storage account blob-service-properties update \
  --resource-group $RESOURCE_GROUP \
  --account-name $STORAGE_ACCOUNT \
  --enable-versioning true

# # Habilitar logs (substitua {subscriptionId}, {resourceGroup} e {workspaceName} pelos valores corretos)
# az monitor diagnostic-settings create \
#   --resource $STORAGE_ACCOUNT \
#   --resource-group $RESOURCE_GROUP \
#   --name "audit-logs" \
#   --logs '[{"category": "StorageRead", "enabled": true}, {"category": "StorageWrite", "enabled": true}]' \
#   --workspace "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroup}/providers/Microsoft.OperationalInsights/workspaces/{workspaceName}"

# Configurar backup
# az backup vault create \
#   --resource-group $RESOURCE_GROUP \
#   --name "backup-vault" \
#   --location $LOCATION

# az backup protection enable-for-azurestorage \
#   --resource-group $RESOURCE_GROUP \
#   --vault-name "backup-vault" \
#   --storage-account $STORAGE_ACCOUNT \
#   --policy-name "DefaultPolicy"

# Configurar RBAC (substitua {user-or-service-principal-id} e {subscriptionId} pelos valores corretos)
# az role assignment create \
#   --assignee "{user-or-service-principal-id}" \
#   --role "Storage Blob Data Contributor" \
#   --scope "/subscriptions/{subscriptionId}/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT"

# Mostrar informações
echo -e "\nBackend criado com sucesso!"
echo "Resource Group: $RESOURCE_GROUP"
echo "Storage Account: $STORAGE_ACCOUNT"
echo "Container: $CONTAINER_NAME"
echo "Tags aplicadas: $TAGS"
