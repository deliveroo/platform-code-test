PATH:= $(PATH):$(GOBIN)
export PATH
SHELL:= env PATH=$(PATH) /bin/bash

ENV?=production
INTERVIEWER?=0
USERNAME?=


tf-apply: tf-init
	cd terraform/environments/$(ENV) && terraform apply -auto-approve

tf-clean:
	find . -type d -a -name .terraform -print0 | xargs -0 rm -rf
	find . -type f -a -name "terraform.tfstate*" -print0 | xargs -0 rm -rf

tf-destroy:
	cd terraform/environments/$(ENV) && terraform destroy

tf-fmt:
	cd terraform/environments/$(ENV) && terraform fmt -recursive

tf-init:
	cd terraform/environments/$(ENV) && terraform init

tf-plan: tf-init
	cd terraform/environments/$(ENV) && terraform plan

user-delete:
	./bin/delete_user $(USERNAME)

user-generate:
	./bin/generate_user $(USERNAME) $(INTERVIEWER)
