ifeq ($(OS),Windows_NT)
	PATH_SEPARATOR := "\"
else
	PATH_SEPARATOR := "/"
endif
reportFolder:=reports
outFilename:=external_plan_test.tfplan
varsFilename:=external_vars.tfvars
outReportFilename:=plan_test.txt

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
