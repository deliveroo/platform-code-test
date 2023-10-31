PATH:= $(PATH):$(GOBIN)
export PATH
SHELL:= env PATH=$(PATH) /bin/bash


tf-apply: tf-init
	cd terraform/environments/production && terraform apply -auto-approve

tf-fmt:
	cd terraform/environments/production && terraform fmt -recursive

tf-init:
	cd terraform/environments/production && terraform init

tf-plan: tf-init
	cd terraform/environments/production && terraform plan
