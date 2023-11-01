export GO111MODULE=on

PWD=$(shell pwd)

SERVICE_NAME?=platform-code-test-app

DOCKER_PUSH_APP_VERSION?=0.0.1
DOCKER_PUSH_AWS_ACCOUNT?=920609328416
DOCKER_PUSH_AWS_REGION?=eu-west-1

DOCKER_BUILD_PLATFORM?=
DOCKER_BUILD_TARGET?=production
DOCKER_BUILD_TAG?=$(SERVICE_NAME)-$(DOCKER_BUILD_TARGET)

PATH:=$(PWD)/bin:$(PATH)
export PATH

export BUILDKIT_PROGRESS=plain
export DOCKER_BUILDKIT=1

ifneq ($(DOCKER_BUILD_PLATFORM),)
export DOCKER_DEFAULT_PLATFORM=${DOCKER_BUILD_PLATFORM}
endif

SHELL:=env PATH=$(PATH) /bin/bash

.PHONY: build
build:
	go install -v .

.PHONY: clean
clean:
	@rm -rf vendor

.PHONY: deps
deps:
	go mod download

.PHONY: docker_build
docker_build:
	docker build \
		-t $(DOCKER_BUILD_TAG) \
		--target $(DOCKER_BUILD_TARGET) \
		.

.PHONY: docker_push_aws
docker_push_aws:
	$(MAKE) docker_build DOCKER_BUILD_PLATFORM=linux/amd64 DOCKER_BUILD_TAG=${DOCKER_BUILD_TAG}-aws
	aws ecr get-login-password --region ${DOCKER_PUSH_AWS_REGION} | \
		docker login --username AWS --password-stdin ${DOCKER_PUSH_AWS_ACCOUNT}.dkr.ecr.${DOCKER_PUSH_AWS_REGION}.amazonaws.com
	docker tag $(shell docker images -q  '${DOCKER_BUILD_TAG}-aws') ${DOCKER_PUSH_AWS_ACCOUNT}.dkr.ecr.${DOCKER_PUSH_AWS_REGION}.amazonaws.com/${SERVICE_NAME}:${DOCKER_PUSH_APP_VERSION}
	docker push ${DOCKER_PUSH_AWS_ACCOUNT}.dkr.ecr.${DOCKER_PUSH_AWS_REGION}.amazonaws.com/${SERVICE_NAME}:${DOCKER_PUSH_APP_VERSION}

.PHONY: docker_run
docker_run: docker_build
	docker run \
		-dit \
		-p 8080:8080 \
		$(DOCKER_BUILD_TAG)

.PHONY: docker_test
docker_test:
	$(MAKE) docker_build DOCKER_BUILD_TARGET=test
	docker run $(SERVICE_NAME)-test

.PHONY: run
run: build
	@$(SERVICE_NAME)

.PHONY: run_src
run_src: deps
	go run main.go

.PHONY: test_all
test_all: deps test_unit

.PHONY: test_unit
test_unit:
	go test -count 1 -timeout=30s -cover -race -v ./...
