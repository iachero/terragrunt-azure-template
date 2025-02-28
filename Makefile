# Removendo as variáveis de cores que estavam causando erros tput
# e simplificando a formatação

# include .env

ARM_CLIENT_ID		?= $(shell grep ARM_CLIENT_ID .env | cut -d '=' -f2)
ARM_CLIENT_SECRET	?= $(shell grep ARM_CLIENT_SECRET .env | cut -d '=' -f2)
ARM_SUBSCRIPTION_ID	?= $(shell grep ARM_SUBSCRIPTION_ID .env | cut -d '=' -f2)
ARM_TENANT_ID		?= $(shell grep ARM_TENANT_ID .env | cut -d '=' -f2)

TF_PLAN_FILE        = tf.plan
VAR_FILE            = terraform.tfvars
# Diretório de trabalho do Terragrunt
TG_WORKING_DIR      = terragrunt

.PHONY: help
help:
	@echo "Comandos disponíveis:"
	@echo "  login         	- Realiza login no Azure usando service principal 🔑"
	@echo "  account_set   	- Define a subscription do Azure 🔑"
	@echo "  init          	- Inicializa o Terragrunt 🔄"
	@echo "  validate      	- Valida o Terragrunt 🔍"
	@echo "  plan          	- Gera o plano de execução do Terragrunt 📝"
	@echo "  apply         	- Aplica as mudanças planejadas 🚀"
	@echo "  destroy       	- Destrói toda a infraestrutura 💀"
	@echo "  output        	- Exibe os outputs do Terragrunt 📝"
	@echo "  all           	- Executa todo o processo (login, init, plan, apply) 🚀"
	@echo "  pc	    		- Executa o pre-commit run -a 🔍"
	@echo "  git    		- Executa o git add, commit e push 🔑"
	@echo "  structure		- Cria estrutura inicial do projeto 📂"
.DEFAULT_GOAL := help

login:
	@echo ""
	@echo "Azure Logout 🔑"
	@az logout
	@echo "Azure Account Clear 🔑"
	@az account clear
	@az config set core.output=table --only-show-errors
	@echo "Azure Login 🔑"
	@az login \
		-u $(ARM_CLIENT_ID) \
		-p $(ARM_CLIENT_SECRET) \
		--tenant $(ARM_TENANT_ID) \
		--service-principal
	@az account set --subscription $(ARM_SUBSCRIPTION_ID)
	@echo "Para carregar as variáveis no ambiente atual, execute manualmente: source .env"

init:
	@echo ""
	@echo "Terragrunt init 🔄"
	@terragrunt run-all init --working-dir $(TG_WORKING_DIR)
validate:
	@echo ""
	@echo "Terragrunt hclfmt e validate 🔍"
	@terragrunt run-all hclfmt --working-dir $(TG_WORKING_DIR)
	@terragrunt run-all validate --working-dir $(TG_WORKING_DIR)

plan: validate
	@echo ""
	@echo "Terragrunt Plan 📝"
	@terragrunt run-all plan --working-dir $(TG_WORKING_DIR)

apply: 
	@echo ""
	@echo "Terragrunt Apply 🚀"
	@terragrunt run-all apply -auto-approve --working-dir $(TG_WORKING_DIR)

destroy: 
	@echo ""
	@echo "Terragrunt Destroy 💀"
	@terragrunt run-all destroy -auto-approve --working-dir $(TG_WORKING_DIR)
output:
	@echo ""
	@echo "Terragrunt Output 📝"
	@terragrunt run-all output --working-dir $(TG_WORKING_DIR)
all: apply

pc:
	@echo ""
	@echo "Pre-commit run -a 🔍"
	@git add .
	@pre-commit run -a

git:
	@echo ""
	@echo "Git add, commit e push 🐙"
	@git add .
	@read -p "Digite sua mensagem de commit: " message; \
	git commit -m "$$message"
	@git push
clean:
	@echo ""
	@echo "Limpando cache do Terragrunt 🗑️"
	@find . -type d -name '.terragrunt-cache' -prune -exec rm -rf {} \;
	@rm -rf /tmp/.terragrunt-cache
	@echo "Limpando cache do Terraform 🗑️"
	@find . -type d -name '.terraform'  -prune -exec rm -rf {} \;
	@find . -type f -name '.terraform.lock.hcl' -exec rm -f {} \;
	@echo "Limpando arquivos :Zone.Identifier 🗑️"
	@find . -type f -name '*:Zone.Identifier' -exec rm -f {} \;
	@echo "Limpando arquivos tf.plan 🗑️"
	@rm -f $(TF_PLAN_FILE)
	@echo "Limpando arquivos terraform.tfstate 🗑️"
	@read -p "Tem certeza que deseja remover os arquivos terraform.tfstate? (y/n) " answer; \
	if [ "$$answer" = "y" ]; then \
		find . -type f -name 'terraform.tfstate*' -exec rm -f {} \; ; \
		echo "Arquivos terraform.tfstate removidos com sucesso 🗑️"; \
	else \
		echo "Operação cancelada 🚫"; \
	fi

structure:
	@echo "Criando estrutura inicial do projeto 📂"
	@mkdir -p terraform/modules/app
	@touch terraform/modules/app/main.tf
	@touch terraform/modules/app/outputs.tf
	@touch terraform/modules/app/variables.tf
	@touch terraform/modules/app/providers.tf
	
	@mkdir -p terraform/modules/db
	@touch terraform/modules/db/main.tf
	@touch terraform/modules/db/outputs.tf
	@touch terraform/modules/db/variables.tf
	@touch terraform/modules/db/providers.tf
	
	@mkdir -p terragrunt/environments/dev/eastus2/resource_groups/001
	@mkdir -p terragrunt/environments/dev/eastus2/resource_groups/002
	@mkdir -p terragrunt/environments/dev/eastus2/virtual_networks/vnet/001
	@mkdir -p terragrunt/environments/dev/eastus2/virtual_networks/peering/001
	@mkdir -p terragrunt/environments/dev/eastus2/compute/vm/001
	@mkdir -p terragrunt/environments/dev/eastus2/compute/aks/001
	@mkdir -p terragrunt/environments/dev/eastus2/databases/postgres_server/001
	
	@cat assets/hcl-templates/rg-terragrunt.hcl > terragrunt/environments/dev/eastus2/resource_groups/001/terragrunt.hcl
	@touch terragrunt/environments/dev/eastus2/resource_groups/002/terragrunt.hcl
	@cat assets/hcl-templates/vnet-terragrunt.hcl > terragrunt/environments/dev/eastus2/virtual_networks/vnet/001/terragrunt.hcl
	@touch terragrunt/environments/dev/eastus2/virtual_networks/peering/001/terragrunt.hcl
	@touch terragrunt/environments/dev/eastus2/compute/vm/001/terragrunt.hcl
	@touch terragrunt/environments/dev/eastus2/compute/aks/001/terragrunt.hcl
	@touch terragrunt/environments/dev/eastus2/databases/postgres_server/001/terragrunt.hcl
	@cat assets/hcl-templates/env_dev.hcl > terragrunt/environments/dev/env_dev.hcl
	
	@mkdir -p terragrunt/environments/prod/brazilsouth/resource_groups/001
	@mkdir -p terragrunt/environments/prod/brazilsouth/resource_groups/002
	@mkdir -p terragrunt/environments/prod/brazilsouth/virtual_networks/vnet/001
	@mkdir -p terragrunt/environments/prod/brazilsouth/virtual_networks/peering/001
	@mkdir -p terragrunt/environments/prod/brazilsouth/compute/vm/001
	@mkdir -p terragrunt/environments/prod/brazilsouth/compute/aks/001
	@mkdir -p terragrunt/environments/prod/brazilsouth/databases/postgres_server/001
	
	@touch terragrunt/environments/prod/brazilsouth/resource_groups/001/terragrunt.hcl
	@touch terragrunt/environments/prod/brazilsouth/resource_groups/002/terragrunt.hcl
	@touch terragrunt/environments/prod/brazilsouth/virtual_networks/vnet/001/terragrunt.hcl
	@touch terragrunt/environments/prod/brazilsouth/virtual_networks/peering/001/terragrunt.hcl
	@touch terragrunt/environments/prod/brazilsouth/compute/vm/001/terragrunt.hcl
	@touch terragrunt/environments/prod/brazilsouth/compute/aks/001/terragrunt.hcl
	@touch terragrunt/environments/prod/brazilsouth/databases/postgres_server/001/terragrunt.hcl
	@touch terragrunt/environments/prod/env_prod.hcl
	
	@mkdir -p terragrunt/environments/hml/eastus2/resource_groups/001
	@touch terragrunt/environments/hml/eastus2/resource_groups/001/terragrunt.hcl
	@touch terragrunt/environments/hml/env_hml.hcl
	
	@cat assets/hcl-templates/root.hcl > terragrunt/root.hcl
	
	@echo "Estrutura do projeto criada com sucesso no caminho: $(PWD) 📂"
	@echo "Para visualizar a estrutura, execute: find . -type d -not -path '*/\.*' | sort"