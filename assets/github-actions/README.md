![Banner Terragrunt](../docs/images/banner-github-actions.png)
# Pipeline CI/CD para Infraestrutura como Código

Este documento descreve o pipeline de CI/CD para gerenciamento de infraestrutura como código usando Terraform e Terragrunt no GitHub Actions.

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Pré-requisitos](#pré-requisitos)
- [Configuração do GitHub](#configuração-do-github)
- [Estrutura do Pipeline](#estrutura-do-pipeline)
- [Parâmetros do Pipeline](#parâmetros-do-pipeline)
- [Variáveis e Segredos](#variáveis-e-segredos)
- [Execução do Pipeline](#execução-do-pipeline)
- [Solução de Problemas](#solução-de-problemas)
- [Melhores Práticas](#melhores-práticas)

## 🔍 Visão Geral

Este pipeline automatiza o processo de provisionamento e gerenciamento de infraestrutura usando Terraform e Terragrunt. Ele suporta múltiplos ambientes (dev, hml, prod) e regiões (eastus2, brazilsouth), permitindo operações como inicialização, validação, planejamento, aplicação e destruição de recursos.

## 🛠️ Pré-requisitos

1. **Repositório GitHub** com permissões para criar workflows
2. **Service Principal do Azure** com permissões adequadas para criar recursos
3. **Conta de Armazenamento do Azure** para armazenar o estado do Terraform
4. **Chave SSH** para acesso a repositórios Git (se necessário)

## ⚙️ Configuração do GitHub

### 1. Configurar Secrets

1. Acesse **Settings** > **Secrets and variables** > **Actions** > **New repository secret**
2. Adicione os seguintes secrets:
   - `ARM_CLIENT_ID`: ID do cliente do Service Principal
   - `ARM_CLIENT_SECRET`: Segredo do cliente
   - `ARM_SUBSCRIPTION_ID`: ID da assinatura do Azure
   - `ARM_TENANT_ID`: ID do tenant do Azure
   - `SSH_PRIVATE_KEY`: Chave SSH privada para acesso a repositórios

### 2. Configurar Environments (opcional)

1. Acesse **Settings** > **Environments** > **New environment**
2. Crie ambientes para `dev`, `hml` e `prod`
3. Configure proteções para o ambiente `prod`:
   - Ative **Required reviewers** e adicione os aprovadores
   - Configure outras proteções conforme necessário

### 3. Configurar Workflow

1. Crie o diretório `.github/workflows` no seu repositório
2. Adicione o arquivo `terragrunt.yml` com a configuração do workflow
3. Faça commit e push para o repositório

## 🏗️ Estrutura do Pipeline

O pipeline é composto por dois jobs principais:

1. **terragrunt**: Executa operações do Terragrunt
   - Instala tfenv e tgenv para gerenciar versões
   - Configura SSH para acesso a repositórios
   - Valida a sintaxe do código
   - Executa a ação solicitada (init, plan, apply, etc.)
   - Mostra outputs quando aplicável

2. **validation**: Solicita aprovação manual após implantação em produção
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

### Secrets do GitHub

- `ARM_CLIENT_ID`: ID do cliente do Service Principal
- `ARM_CLIENT_SECRET`: Segredo do cliente
- `ARM_SUBSCRIPTION_ID`: ID da assinatura do Azure
- `ARM_TENANT_ID`: ID do tenant do Azure
- `SSH_PRIVATE_KEY`: Chave SSH privada

### Variáveis do Workflow

- `ENV_NAME`: Nome do ambiente (derivado do parâmetro)
- `REGION`: Região do Azure (derivada do parâmetro)
- `ACTION`: Ação a ser executada (derivada do parâmetro)
- `TF_STATE_RG`: Grupo de recursos para o estado do Terraform
- `TF_STATE_SA`: Conta de armazenamento para o estado do Terraform
- `TF_STATE_CONTAINER`: Container para o estado do Terraform

## 🚀 Execução do Pipeline

### Executar o Pipeline

1. Acesse a aba **Actions** no seu repositório
2. Selecione o workflow **Terragrunt CI/CD**
3. Clique em **Run workflow**
4. Selecione os parâmetros desejados:
   - **Ação**: Escolha a operação a ser executada
   - **Versão do Terraform**: Selecione a versão do Terraform
   - **Versão do Terragrunt**: Selecione a versão do Terragrunt
   - **Ambiente**: Selecione o ambiente alvo
   - **Região**: Selecione a região do Azure
5. Clique em **Run workflow**

### Fluxo de Trabalho Recomendado

1. Execute `init` para inicializar o Terragrunt
2. Execute `validate` para validar a configuração
3. Execute `plan` para visualizar as mudanças propostas
4. Execute `apply` para aplicar as mudanças
5. Use `output` para visualizar os outputs após a aplicação
6. Use `destroy` quando necessário para remover recursos

## 🔧 Solução de Problemas

### Problemas Comuns

1. **Erro de autenticação no Azure**:
   - Verifique se os secrets `ARM_*` estão configurados corretamente
   - Verifique se o Service Principal tem as permissões necessárias

2. **Erro de acesso SSH**:
   - Verifique se o secret `SSH_PRIVATE_KEY` está configurado corretamente
   - Verifique se a chave tem acesso aos repositórios necessários

3. **Erro ao instalar Terraform/Terragrunt**:
   - Verifique se as versões especificadas estão disponíveis
   - Tente usar a versão `latest` para obter a versão mais recente

4. **Erro de acesso ao estado remoto**:
   - Verifique se o grupo de recursos, conta de armazenamento e container existem
   - Verifique se o Service Principal tem acesso à conta de armazenamento

### Logs Verbosos

Para reduzir a verbosidade dos logs do Terragrunt, você pode adicionar a opção `--log-disable` ou `--log-level error` aos comandos do Terragrunt no arquivo do workflow.

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
   - Mantenha segredos em GitHub Secrets
   - Configure proteções para ambientes de produção
   - Limite o acesso ao workflow apenas a usuários autorizados

5. **Backup e Recuperação**:
   - Mantenha backups do estado do Terraform
   - Documente procedimentos de recuperação para cenários de falha

Maintained by 👨🏻‍💻 [@diogofrj](https://github.com/diogofrj) 