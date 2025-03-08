![Banner Terragrunt](../docs/images/banner-azure-pipelines.png)
# Pipeline CI/CD para Infraestrutura como Código

Este documento descreve o pipeline de CI/CD para gerenciamento de infraestrutura como código usando Terraform e Terragrunt no Azure DevOps.

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Pré-requisitos](#pré-requisitos)
- [Configuração do Azure DevOps](#configuração-do-azure-devops)
- [Estrutura do Pipeline](#estrutura-do-pipeline)
- [Parâmetros do Pipeline](#parâmetros-do-pipeline)
- [Variáveis e Segredos](#variáveis-e-segredos)
- [Execução do Pipeline](#execução-do-pipeline)
- [Solução de Problemas](#solução-de-problemas)
- [Melhores Práticas](#melhores-práticas)

## 🔍 Visão Geral

Este pipeline automatiza o processo de provisionamento e gerenciamento de infraestrutura usando Terraform e Terragrunt. Ele suporta múltiplos ambientes (dev, hml, prod) e regiões (eastus2, brazilsouth), permitindo operações como inicialização, validação, planejamento, aplicação e destruição de recursos.

## 🛠️ Pré-requisitos

1. **Azure DevOps Project** com permissões para criar pipelines
2. **Service Principal do Azure** com permissões adequadas para criar recursos
3. **Conta de Armazenamento do Azure** para armazenar o estado do Terraform
4. **Chave SSH** para acesso a repositórios Git (se necessário)

## ⚙️ Configuração do Azure DevOps

### 1. Criar Service Connection

1. Acesse **Project Settings** > **Service connections** > **New service connection**
2. Selecione **Azure Resource Manager**
3. Escolha **Service Principal (automatic)** ou **Service Principal (manual)**
4. Preencha as informações necessárias
5. Nomeie a conexão como `SP-MPN` (ou atualize o valor da variável `serviceConnectionName` no pipeline)
6. Clique em **Save**

### 2. Configurar Grupo de Variáveis

1. Acesse **Pipelines** > **Library** > **+ Variable group**
2. Nomeie o grupo como `MPN-VARS`
3. Adicione as seguintes variáveis:
   - `ARM_CLIENT_ID`: ID do cliente do Service Principal
   - `ARM_CLIENT_SECRET`: Segredo do cliente (marque como segredo)
   - `ARM_SUBSCRIPTION_ID`: ID da assinatura do Azure
   - `ARM_TENANT_ID`: ID do tenant do Azure
4. Clique em **Save**

### 3. Adicionar Arquivo Seguro (Chave SSH)

1. Acesse **Pipelines** > **Library** > **Secure files** > **+ Secure file**
2. Faça upload do arquivo `id_rsa` (chave SSH privada)
3. Clique em **OK**

### 4. Configurar Pipeline

1. Acesse **Pipelines** > **New pipeline**
2. Selecione o repositório onde o código está armazenado
3. Selecione **Existing Azure Pipelines YAML file**
4. Selecione o caminho para o arquivo `azure-pipelines.yml`
5. Clique em **Continue** e depois em **Run**

## 🏗️ Estrutura do Pipeline

O pipeline é composto por dois estágios principais:

1. **Infrastructure**: Executa operações do Terragrunt
   - Instala tfenv e tgenv para gerenciar versões
   - Configura SSH para acesso a repositórios
   - Valida a sintaxe do código
   - Executa a ação solicitada (init, plan, apply, etc.)
   - Mostra outputs quando aplicável

2. **Validation**: Solicita aprovação manual após implantação em produção
   - Ativado apenas para ações de `apply` no ambiente `prod`
   - Permite validação humana das mudanças aplicadas

## 🎛️ Parâmetros do Pipeline

O pipeline aceita os seguintes parâmetros:

| Parâmetro | Descrição | Valores Padrão | Valores Possíveis |
|-----------|-----------|----------------|-------------------|
| `action` | Ação a ser executada | `plan` | `init`, `validate`, `plan`, `apply`, `destroy`, `output` |
| `terraform_version` | Versão do Terraform | `1.10.5` | `1.10.5`, `1.9.8`, `1.8.0`, `1.7.5`, `latest` |
| `terragrunt_version` | Versão do Terragrunt | `0.73.14` | `0.73.14`, `0.67.9`, `0.53.8`, `0.48.0`, `latest` |
| `environment` | Ambiente alvo | `dev` | `dev`, `hml`, `prod` |
| `region` | Região do Azure | `eastus2` | `eastus2`, `brazilsouth` |

## 🔐 Variáveis e Segredos

### Grupo de Variáveis (MPN-VARS)

- `ARM_CLIENT_ID`: ID do cliente do Service Principal
- `ARM_CLIENT_SECRET`: Segredo do cliente
- `ARM_SUBSCRIPTION_ID`: ID da assinatura do Azure
- `ARM_TENANT_ID`: ID do tenant do Azure

### Variáveis do Pipeline

- `serviceConnectionName`: Nome da conexão de serviço do Azure
- `ENV_NAME`: Nome do ambiente (derivado do parâmetro)
- `REGION`: Região do Azure (derivada do parâmetro)
- `TF_STATE_RG`: Grupo de recursos para o estado do Terraform
- `TF_STATE_SA`: Conta de armazenamento para o estado do Terraform
- `TF_STATE_CONTAINER`: Container para o estado do Terraform

## 🚀 Execução do Pipeline

### Executar o Pipeline

1. Acesse **Pipelines** > Selecione o pipeline
2. Clique em **Run pipeline**
3. Selecione os parâmetros desejados:
   - **Ação**: Escolha a operação a ser executada
   - **Versão do Terraform**: Selecione a versão do Terraform
   - **Versão do Terragrunt**: Selecione a versão do Terragrunt
   - **Ambiente**: Selecione o ambiente alvo
   - **Região**: Selecione a região do Azure
4. Clique em **Run**

### Fluxo de Trabalho Recomendado

1. Execute `init` para inicializar o Terragrunt
2. Execute `validate` para validar a configuração
3. Execute `plan` para visualizar as mudanças propostas
4. Execute `apply` para aplicar as mudanças
5. Use `output` para visualizar os outputs após a aplicação
6. Use `destroy` quando necessário para remover recursos

## 🔧 Solução de Problemas

### Problemas Comuns

1. **Erro de conexão de serviço**:
   - Verifique se a conexão de serviço `SP-MPN` existe e está configurada corretamente
   - Verifique se o Service Principal tem as permissões necessárias

2. **Variáveis de ambiente não definidas**:
   - Verifique se o grupo de variáveis `MPN-VARS` está configurado corretamente
   - Verifique se as variáveis ARM_* estão definidas no grupo

3. **Erro ao instalar Terraform/Terragrunt**:
   - Verifique se as versões especificadas estão disponíveis
   - Tente usar a versão `latest` para obter a versão mais recente

4. **Erro de acesso ao estado remoto**:
   - Verifique se o grupo de recursos, conta de armazenamento e container existem
   - Verifique se o Service Principal tem acesso à conta de armazenamento

### Logs Verbosos

Para reduzir a verbosidade dos logs do Terragrunt, você pode adicionar a opção `--log-disable` ou `--log-level error` aos comandos do Terragrunt no arquivo do pipeline.

## 🌟 Melhores Práticas

1. **Controle de Versão**:
   - Mantenha o código do Terraform e Terragrunt sob controle de versão
   - Use branches para desenvolvimento e teste antes de mesclar com a main

2. **Ambientes Separados**:
   - Use ambientes separados para desenvolvimento, homologação e produção
   - Aplique mudanças progressivamente: dev → hml → prod

3. **Revisão de Código**:
   - Sempre revise o plano do Terraform antes de aplicar mudanças
   - Use pull requests para revisão de código antes de mesclar

4. **Segurança**:
   - Mantenha segredos em variáveis seguras ou Azure Key Vault
   - Limite o acesso ao pipeline apenas a usuários autorizados

5. **Backup e Recuperação**:
   - Mantenha backups do estado do Terraform
   - Documente procedimentos de recuperação para cenários de falha

Maintained by 👨🏻‍💻 [@diogofrj](https://github.com/diogofrj)