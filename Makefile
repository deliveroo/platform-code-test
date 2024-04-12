PATH:= $(PATH):$(GOBIN)
export PATH
SHELL:= env PATH=$(PATH) /bin/bash

INTERVIEW_TYPE ?= $(shell grep -v '^\#' INTERVIEW_TYPE | awk '{print $$1}' | grep -v '^$$' | head -n 1)
ENV?=production-$(INTERVIEW_TYPE)
INTERVIEWER?=0
USERNAME?=

.PHONY: tf-apply
tf-apply: tf-init
	cd terraform/environments/$(ENV) && terraform apply -auto-approve

.PHONY: tf-clean
tf-clean:
	find . -type d -a -name .terraform -print0 | xargs -0 rm -rf
	find . -type f -a -name "terraform.tfstate*" -print0 | xargs -0 rm -rf

.PHONY: tf-destroy
tf-destroy: .check-interview-type
	cd terraform/environments/$(ENV) && terraform destroy

.PHONY: tf-fmt
tf-fmt: .check-interview-type
	cd terraform/environments/$(ENV) && terraform fmt -recursive

.PHONY: tf-init
tf-init: .check-interview-type
	cd terraform/environments/$(ENV) && terraform init

.PHONY: tf-plan
tf-plan: tf-init
	cd terraform/environments/$(ENV) && terraform plan

.PHONY: user-delete
user-delete:
	./bin/delete_user $(USERNAME)

.PHONY: user-generate
user-generate:
	./bin/generate_user $(USERNAME) $(INTERVIEWER)

.PHONY: eks-config
eks-config:
	aws eks update-kubeconfig --name apps --region eu-west-1

.PHONY: .check-interview-type
.check-interview-type:
	@[ -d terraform/environments/$(ENV) ] || (echo "Could not find Terraform directory, is INTERVIEW_TYPE file updated?" >&2 && exit 1)