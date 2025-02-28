# Aula: Terragrunt Scaffold - Criando Módulos com Boilerplate

O que é o Terragrunt Scaffold?
O Terragrunt Scaffold é uma funcionalidade poderosa que gera automaticamente arquivos de configuração (terragrunt.hcl) com base em um módulo Terraform existente. Ele analisa o módulo, identifica suas variáveis de entrada (inputs) e cria um arquivo terragrunt.hcl pré-configurado com todos os inputs necessários.
Como configurar seu módulo para o Scaffolding
Para que o Terragrunt Scaffold preencha corretamente os inputs necessários no arquivo gerado, seu módulo Terraform precisa seguir algumas práticas:

```hcl:terraform-azurerm-rg-module/variables.tf
variable "name" {
  description = "O nome do Resource Group a ser criado"
  type        = string
}

variable "location" {
  description = "A localização do Azure onde o Resource Group será criado"
  type        = string
}

variable "tags" {
  description = "Tags a serem aplicadas ao Resource Group"
  type        = map(string)
  default     = {}
}
```

**Pontos importantes:**
1. **Descrições detalhadas**: Sempre inclua descrições claras para cada variável
2. **Tipo de dados definido**: Sempre declare o tipo de cada variável
3. **Valores padrão quando apropriado**: Use `default` para variáveis opcionais

Para projetos avançados, você pode criar modelos personalizados incluindo uma pasta `.boilerplate` no seu módulo:

```
terraform-azurerm-rg-module/
├── main.tf
├── variables.tf
├── outputs.tf
└── .boilerplate/
    ├── boilerplate.yml
    └── terragrunt.hcl.tmpl
```

## Como usar o Terragrunt Scaffold

A sintaxe básica é:

```bash
terragrunt scaffold <URL_DO_MÓDULO> [URL_DO_TEMPLATE] [--var] [--var-file] [--no-include-root] [--root-file-name]
```

Exemplo de uso:

```bash
# Scaffold básico
terragrunt scaffold git@ssh.dev.azure.com:v3/Sinqia/Terraform/terraform-azurerm-rg-module

# Usando uma versão específica do módulo
terragrunt scaffold git@ssh.dev.azure.com:v3/Sinqia/Terraform/terraform-azurerm-rg-module --var=Ref=v1.0.2

# Sem incluir o arquivo root
terragrunt scaffold git@ssh.dev.azure.com:v3/Sinqia/Terraform/terraform-azurerm-rg-module --no-include-root
```

## O que o Scaffold gera?

O Terragrunt Scaffold gera um arquivo `terragrunt.hcl` com:

1. **Referência ao módulo**: Configuração da fonte (source) do módulo
2. **Inputs obrigatórios**: Todas as variáveis sem valor padrão serão listadas como TODOs
3. **Inputs opcionais**: Variáveis com valores padrão serão comentadas
4. **Inclusão do arquivo root**: Por padrão, adiciona uma referência ao arquivo root.hcl

Exemplo de saída:

```hcl
# Este é um módulo Terragrunt gerado pelo boilerplate.
terraform {
  source = "git::ssh://git@ssh.dev.azure.com/v3/Sinqia/Terraform/terraform-azurerm-rg-module?ref=v1.0.1"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  # --------------------------------------------------------------------------------------------------------------------
  # Variáveis de entrada obrigatórias
  # --------------------------------------------------------------------------------------------------------------------

  # Tipo: string
  # Descrição: O nome do Resource Group a ser criado
  name = "" # TODO: preencher valor

  # Tipo: string
  # Descrição: A localização do Azure onde o Resource Group será criado
  location = "" # TODO: preencher valor

  # --------------------------------------------------------------------------------------------------------------------
  # Variáveis de entrada opcionais
  # Descomente as que você deseja definir
  # --------------------------------------------------------------------------------------------------------------------

  # Tipo: map(string)
  # Descrição: Tags a serem aplicadas ao Resource Group
  # tags = {}
}
```

## Criando modelos personalizados

Para personalizar o que é gerado, você pode criar um template personalizado:

1. Crie uma pasta `.boilerplate` no seu módulo
2. Adicione um arquivo `boilerplate.yml` com a configuração
3. Adicione templates personalizados (ex: `terragrunt.hcl.tmpl`)

Exemplo de arquivo `boilerplate.yml`:

```yaml
variables:
  Ref:
    description: "Versão do módulo a ser utilizada"
    default: "v1.0.1"
  EnableRootInclude:
    description: "Incluir referência ao root.hcl"
    default: true
  RootFileName:
    description: "Nome do arquivo de configuração root"
    default: "root.hcl"

templates:
  - source: "terragrunt.hcl.tmpl"
    destination: "terragrunt.hcl"
```

## Dicas para uso eficiente

1. **Use com integração contínua**: Automatize a criação de novos módulos
2. **Mantenha documentação atualizada**: As descrições das variáveis serão usadas como documentação
3. **Versione seus módulos**: Use tags para controlar versões
4. **Padronize seus módulos**: Seguir padrões facilita o uso do scaffold

## Por que usar o Terragrunt Scaffold?

1. **Produtividade**: Crie novos módulos rapidamente
2. **Padronização**: Garante que todos sigam o mesmo padrão
3. **Documentação embutida**: As descrições das variáveis funcionam como documentação
4. **Redução de erros**: Identifica automaticamente variáveis obrigatórias

O Terragrunt Scaffold é particularmente útil em equipes grandes onde a padronização é importante e para novos membros que precisam entender rapidamente como usar os módulos existentes.

[Fonte: Documentação oficial do Terragrunt](https://terragrunt.gruntwork.io/docs/features/scaffold/)