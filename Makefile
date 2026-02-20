PATH:= $(PATH):$(GOBIN)
export PATH
SHELL:= env PATH=$(PATH) /bin/bash

AWS_ACCOUNT ?= $(shell aws sts get-caller-identity --query "Account" --output text)
ENV ?= production

.PHONY: tf-apply
tf-apply: tf-init
	cd terraform/environments/$(ENV) && terraform apply -auto-approve

.PHONY: tf-clean
tf-clean:
	find . -type d -a -name .terraform -print0 | xargs -0 rm -rf
	find . -type f -a -name "terraform.tfstate*" -print0 | xargs -0 rm -rf
	find . -type f -a -name ".terraform.lock.hcl" -print0 | xargs -0 rm -rf

.PHONY: tf-destroy
tf-destroy: tf-init .k8s-destroy
	cd terraform/environments/$(ENV) && terraform destroy -auto-approve

.PHONY: tf-fmt
tf-fmt:
	cd terraform/environments/$(ENV) && terraform fmt -recursive

.PHONY: tf-init
tf-init: .pre-validate
	cd terraform/environments/$(ENV) && terraform init

.PHONY: tf-plan
tf-plan: tf-init
	cd terraform/environments/$(ENV) && terraform plan

.PHONY: k8s-config
k8s-config: .pre-validate
	aws eks update-kubeconfig --name apps --region eu-west-1 --role-arn arn:aws:iam::$(AWS_ACCOUNT):role/kubernetes-cluster-admin

.PHONY: .k8s-destroy
.k8s-destroy: k8s-config
	kubectl delete ingress platform-code-test-app -n default

.PHONY: .pre-validate
.pre-validate:
	@bin/check_account "$(AWS_ACCOUNT)"
