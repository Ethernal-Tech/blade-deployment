TERRAFORM_DIR:=./changeme

init:
	cd ${TERRAFORM_DIR }; \
	terraform init -backend-config=config.s3.tfbackend
.PHONY: init


create:
	cd ${TERRAFORM_DIR }; \
	sudo rm -rf /tmp/*
	terraform apply -auto-approve
	
.PHONY: create

keys:
	cd ${TERRAFORM_DIR }; \
	terraform output pk_ansible > ~/private.key
	chmod 600 ~/private.key 
	eval "$(ssh-agent)"
	ssh-add ~/private.key
.PHONY: keys

show:
	cd ${TERRAFORM_DIR }; \
	terraform show
.PHONY: show

validate:
	cd ${TERRAFORM_DIR }; \
	terraform validate
.PHONY: validate

state:
	cd ${TERRAFORM_DIR }; \
	terraform state list
.PHONY: state

destroy:
	cd ${TERRAFORM_DIR }; \
	terraform destroy --auto-approve
.PHONY: destroy