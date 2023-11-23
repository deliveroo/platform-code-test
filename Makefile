# Setup
export

SHELL := /bin/bash -o errexit -o nounset -o pipefail

MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

VERBOSE ?= false
ifeq (${VERBOSE}, false)
	# --silent drops the need to prepend `@` to suppress command output
	MAKEFLAGS += --silent
endif

# Variables
USER_ID  := $(shell id -u)
GROUP_ID := $(shell id -g)

ENV ?= production

TERRAFORM_VERSION ?= 1.5

# Applications
DOCKER         ?= docker
DOCKER_COMPOSE ?= $(DOCKER) compose

TERRAFORM ?= $(DOCKER_COMPOSE) run --rm terraform -chdir=terraform/environments/${ENV}

# Helpers
all: init plan ## run init and plan

.PHONY: tinker
tinker: ## drop into a container with terraform and the code loaded
	$(DOCKER_COMPOSE) run --rm --entrypoint sh terraform

.PHONY: fmt
fmt: ## format the terraform code
	$(TERRAFORM) fmt -recursive

# Dependencies
.PHONY: init
init: ## initialize terraform and download dependencies
	$(TERRAFORM) init

# Building
.PHONY: plan
plan: ## see a plan of the infrastructure changes
	$(TERRAFORM) plan

# Deploying
.PHONY: apply
apply:  ## apply the infrastructure
	$(TERRAFORM) apply -auto-approve

.PHONY: destroy
destroy: ## destroy the infrastructure
	$(TERRAFORM) destroy

# Cleaning
.PHONY: clean
clean: ## remove build artifacts
	find . -type d -a -name .terraform -print0 | xargs -0 rm -rf
	find . -type f -a -name "terraform.tfstate*" -print0 | xargs -0 rm -rf

.PHONY: clean-docker
clean-docker: ## clean docker compose images/containers
	$(DOCKER_COMPOSE) down --rmi all -v
	$(DOCKER_COMPOSE) rm --stop --force -v

.PHONY: clean-all
clean-all: clean clean-docker ## reset the project to a totally clean state

# Make
print-% :
	echo -n $* = $($*)

.PHONY: help
help:
	grep -Eh '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
