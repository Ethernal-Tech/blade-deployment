include .env

ifeq ($(OS),Windows_NT)
	PATH_SEPARATOR := "\"
else
	PATH_SEPARATOR := "/"
endif
reportFolder:=reports
outFilename:=external_plan_test.tfplan
varsFilename:=external_vars.tfvars
outReportFilename:=plan_test.txt
ANSIBLE_PLAYBOOK_PATH?=./ansible
ansible-playbook = ansible-playbook --inventory ./inventory/aws_ec2.yml
ansible = ansible --inventory ./inventory/aws_ec2.yml


keys:
	terraform output pk_ansible > ~/private.key
	chmod 600 ~/private.key
	eval "$(ssh-agent)"
	ssh-add ~/private.key
.PHONY: keys

# Init target
init:
	@echo "Running init from external path."
	terraform init -backend-config=config.s3.tfbackend
.PHONY: init

plan: init
	@echo "Running plan from external path."
	@echo ${PWD}
	mkdir -p ${reportFolder}

.PHONY: plan
# Show target
show:
	@echo "Running show from external path."
	terraform show
.PHONY: show
# Validate target
validate:
	@echo "Running validate from external path."
	terraform validate -no-color
.PHONY: validate
# State target
state:
	@echo "Running state from external path."
	terraform state list -no-color
.PHONY: state
# Destroy target
destroy:
	@echo "Running destroy from external path."
	mkdir -p ${reportFolder}
	terraform destroy -no-color -auto-approve > .${PATH_SEPARATOR}${reportFolder}${PATH_SEPARATOR}${outFilename}
# TODO copy report to S3, delete local file
.PHONY: destroy
# Apply target
apply: init
	@echo "Running apply from external path."
	mkdir -p ${reportFolder}
	terraform apply -no-color -var-file=${varsFilename} -auto-approve > .${PATH_SEPARATOR}${reportFolder}${PATH_SEPARATOR}${outFilename}
# TODO copy report to S3, delete local file
.PHONY: apply


lint:
	tflint --disable-rule=terraform_required_providers --disable-rule=terraform_required_version --recursive
.PHONY: lint

fix:
	tflint --disable-rule=terraform_required_providers --disable-rule=terraform_required_version --fix --recursive
.PHONY: fix

params:
	for param in $$(aws ssm describe-parameters --query "Parameters[?contains(Name, 'mmnet')].Name" --output text); do \
	   echo $$param; \
				aws ssm delete-parameter  --name $$param; \
	done
.PHONY: params

##@ Ansible

inventory: ## Check the playbook inventory.
	@cd $(ANSIBLE_PLAYBOOK_PATH) && ansible-inventory --graph --inventory ./inventory/aws_ec2.yml
.PHONY: inventory

ping: ## Ping the ansible nodes of a playbook.
	@cd $(ANSIBLE_PLAYBOOK_PATH) && $(ansible) testnode -m ping
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

run-test: ## Run a main playbook.
	cd $(ANSIBLE_PLAYBOOK_PATH) && $(ansible-playbook) test.yml
.PHONY: run-test

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
