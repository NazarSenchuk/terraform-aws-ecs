.PHONY: init plan apply destroy fmt validate

VARS="demo.tfvars"

init:
	terraform init

plan:
	terraform plan -var-file=$(VARS)

apply:
	terraform apply -var-file=$(VARS) -auto-approve

destroy:
	terraform destroy -var-file=$(VARS) -auto-approve

fmt:
	terraform fmt -recursive

validate:
	terraform validate

lint:
	tflint
	tfsec .

all: fmt validate plan
