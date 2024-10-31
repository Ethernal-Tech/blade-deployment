help:
	@awk 'BEGIN {FS = ":.*##"; printf "Usage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
.PHONY: help



##@ Lint

fmt: ## Run terraform fmt against tf code.
	@terraform fmt -recursive && terraform validate
.PHONY: fmt

ansible-lint: ## Run ansible-lint against ansible code.
	@if [ -e ansible/requirements.yml ]; then \
		ansible-galaxy install -r ./ansible/requirements.yml; \
	fi; \
	ansible-lint -c .ansible-lint ./ansible
.PHONY: ansible-lint

yamllint: ## Run yamllint against ansible code.
	@yamllint -c .yamllint.yml ansible
.PHONY: yamllint

lint: fmt ansible-lint yamllint ## Run all of these tools against tf and ansible code.
.PHONY: lint



##@ Configs
S3_BUCKET?=<BUCKET_NAME>
TERRAFORM_LOCAL_TFVARS?=local.tfvars
TERRAFORM_BACKEND_S3?=backend.hcl.s3
ANSIBLE_PLAYBOOK_PATH?=./ansible
ansible-playbook = ansible-playbook --inventory ./inventory/aws_ec2.yml --vault-password-file=../password.txt --extra-vars "@../local.yml"
ansible = ansible --inventory ./inventory/aws_ec2.yml --vault-password-file=../password.txt --extra-vars "@../local.yml"

download-requirements: ## Download ansible and terraform pre-configure valirable files.
	@aws s3 sync s3://${S3_BUCKET}/configs/ . ; \
	chmod 400 *.sk; \
	mv explorer-changes ${ANSIBLE_PLAYBOOK_PATH}/roles/explorer/changes; \
	mv faucet-changes ${ANSIBLE_PLAYBOOK_PATH}/roles/faucet/changes
.PHONY: download-requirements



##@ Terraform

init: ## Initializing terraform.
	@terraform init -backend-config=${TERRAFORM_BACKEND_S3}
.PHONY: init

plan: ## Plan of the infrastructure.
	@terraform plan -var-file=${TERRAFORM_LOCAL_TFVARS}
.PHONY: plan

apply: ## Deploy the infrastructure.
	@read -r -p "Are you sure you want to proceed? (y/n) " answer; \
	if [ "$$answer" != "$${answer#[Yy]}" ]; then \
		echo "Confirmed. Proceeding with the operation."; \
	else \
		echo "Operation cancelled."; \
		exit; \
	fi; \
	terraform apply -var-file=${TERRAFORM_LOCAL_TFVARS}
.PHONY: apply

destroy: ## Destroy the infrastructure.
	@read -r -p "Are you sure you want to proceed? (y/n) " answer; \
	if [ "$$answer" != "$${answer#[Yy]}" ]; then \
		echo "Confirmed. Proceeding with the operation."; \
	else \
		echo "Operation cancelled."; \
		exit; \
	fi; \
	terraform destroy -var-file=${TERRAFORM_LOCAL_TFVARS}
.PHONY: destroy



##@ Ansible

inventory: ## Check the playbook inventory. 
	@cd $(ANSIBLE_PLAYBOOK_PATH) && ansible-inventory --graph --inventory ./inventory/aws_ec2.yml
.PHONY: inventory

ping: ## Ping the ansible nodes of a playbook.
	@cd $(ANSIBLE_PLAYBOOK_PATH) && $(ansible) all -m ping
.PHONY: ping

run-playbook: ## Run a main playbook.
	@read -r -p "Are you sure you want to proceed? (y/n) " answer; \
	if [ "$$answer" != "$${answer#[Yy]}" ]; then \
		echo "Confirmed. Proceeding with the operation."; \
	else \
		echo "Operation cancelled."; \
		exit; \
	fi; \
	cd $(ANSIBLE_PLAYBOOK_PATH) && $(ansible-playbook) site.yml
.PHONY: run-playbook

upload-logs: ## Run a playbook for uploading blade logs.
	@read -r -p "Are you sure you want to proceed? (y/n) " answer; \
	if [ "$$answer" != "$${answer#[Yy]}" ]; then \
		echo "Confirmed. Proceeding with the operation."; \
	else \
		echo "Operation cancelled."; \
		exit; \
	fi; \
	cd $(ANSIBLE_PLAYBOOK_PATH) && $(ansible-playbook) upload-logs.yml
.PHONY: upload-logs

upload-data: ## Run a playbook for uploading blade data.
	@read -r -p "Are you sure you want to proceed? (y/n) " answer; \
	if [ "$$answer" != "$${answer#[Yy]}" ]; then \
		echo "Confirmed. Proceeding with the operation."; \
	else \
		echo "Operation cancelled."; \
		exit; \
	fi; \
	cd $(ANSIBLE_PLAYBOOK_PATH) && $(ansible-playbook) upload-data.yml
.PHONY: upload-logs

clear-syslog: ## Clear syslog on validators and fullnodes.
	@read -r -p "Are you sure you want to proceed? (y/n) " answer; \
	if [ "$$answer" != "$${answer#[Yy]}" ]; then \
		echo "Confirmed. Proceeding with the operation."; \
	else \
		echo "Operation cancelled."; \
		exit; \
	fi; \
	cd ${ANSIBLE_PLAYBOOK_PATH} && ${ansible} validator:fullnode -m shell -b -a 'truncate -s 0 /var/log/syslog'
.PHONY: clear-syslog

delete-saved-logs: ## Delete logs created and stored by logrotate
	@read -r -p "Are you sure you want to proceed? (y/n) " answer; \
	if [ "$$answer" != "$${answer#[Yy]}" ]; then \
		echo "Confirmed. Proceeding with the operation."; \
	else \
		echo "Operation cancelled."; \
		exit; \
	fi; \
	cd ${ANSIBLE_PLAYBOOK_PATH} && ${ansible} validator:fullnode -m shell -b -a 'rm -rf /var/lib/blade/logs/*'
.PHONY: delete-saved-logs

reset-blade: ## Perform reset on the blade service.
	@read -r -p "Are you sure you want to proceed? (y/n) " answer; \
	if [ "$$answer" != "$${answer#[Yy]}" ]; then \
		echo "Confirmed. Proceeding with the operation."; \
	else \
		echo "Operation cancelled."; \
		exit; \
	fi; \
	cd ${ANSIBLE_PLAYBOOK_PATH}; \
	${ansible} validator:fullnode -m shell -b -a 'systemctl stop blade; rm -rf /var/lib/blade/*; rm -rf /var/lib/bootstrap; rm -rf /opt/blade; rm -rf /usr/local/go'; \
	${ansible-playbook} --tags blade site.yml
.PHONY: reset-blade

reset-explorer:  ## Perform reset on the explorer.
	@read -r -p "Are you sure you want to proceed? (y/n) " answer; \
	if [ "$$answer" != "$${answer#[Yy]}" ]; then \
		echo "Confirmed. Proceeding with the operation."; \
	else \
		echo "Operation cancelled."; \
		exit; \
	fi; \
	cd ${ANSIBLE_PLAYBOOK_PATH}; \
	${ansible} explorer -m shell -b -a 'systemctl stop explorer'; \
	${ansible} explorer -m shell -b -u explorer -a 'set -a; source /opt/blockscout/variables.env; set +a; mix deps.get; mix local.hex --force; mix do ecto.drop, ecto.create, ecto.migrate chdir=/opt/blockscout executable=/bin/bash'; \
	${ansible} explorer -m shell -b -a 'systemctl restart explorer'; \
	${ansible-playbook} --tags explorer site.yml
.PHONY: reset-explorer

reset-faucet: ## Perform reset on the faucet service.
	@read -r -p "Are you sure you want to proceed? (y/n) " answer; \
	if [ "$$answer" != "$${answer#[Yy]}" ]; then \
		echo "Confirmed. Proceeding with the operation."; \
	else \
		echo "Operation cancelled."; \
		exit; \
	fi; \
	cd ${ANSIBLE_PLAYBOOK_PATH}; \
	${ansible} explorer -m shell -b -a 'systemctl stop faucet; rm -rf /opt/eth-faucet'; \
	${ansible-playbook} --tags faucet site.yml
.PHONY: reset-faucet

full-reset: ## Perform a full reset.
	@read -r -p "Are you sure you want to proceed? (y/n) " answer; \
	if [ "$$answer" != "$${answer#[Yy]}" ]; then \
		echo "Confirmed. Proceeding with the operation."; \
	else \
		echo "Operation cancelled."; \
		exit; \
	fi; \
	cd ${ANSIBLE_PLAYBOOK_PATH}; \
	${ansible} validator:fullnode -m shell -b -a 'systemctl stop blade; rm -rf /var/lib/blade/*; rm -rf /var/lib/bootstrap; rm -rf /opt/blade; rm -rf /usr/local/go'; \
	${ansible-playbook} --tags blade site.yml; \
	${ansible} explorer -m shell -b -a 'systemctl stop explorer'; \
	${ansible} explorer -m shell -b -u explorer -a 'set -a; source /opt/blockscout/variables.env; set +a; mix local.hex --force; mix do ecto.drop, ecto.create, ecto.migrate chdir=/opt/blockscout executable=/bin/bash'; \
	${ansible} explorer -m shell -b -a 'systemctl restart explorer'; \
	${ansible-playbook} --tags explorer site.yml; \
	${ansible} explorer -m shell -b -a 'systemctl stop faucet; rm -rf /opt/eth-faucet'; \
	${ansible-playbook} --tags faucet site.yml
.PHONY: full-reset

setup-explorer-and-faucet: ## Configure the explorer and faucet once the instance is up in the network.
	@read -r -p "Are you sure you want to proceed? (y/n) " answer; \
	if [ "$$answer" != "$${answer#[Yy]}" ]; then \
		echo "Confirmed. Proceeding with the operation."; \
	else \
		echo "Operation cancelled."; \
		exit; \
	fi; \
	cd ${ANSIBLE_PLAYBOOK_PATH}; \
	${ansible-playbook} site.yml --tags always,init,explorer,faucet,logrotate --limit explorer
.PHONY: setup-explorer-and-faucet
