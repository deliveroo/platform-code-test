# platform-code-test

A live coding to test for potential platform engineers.

## Environments

### Production

This is where the candidate will be working during the test, it should be destroyed and recreated between tests.

### Common

This contains resources that should persist between tests, will need to be applied before the production env

## Usage

### Requirements

* [tfenv](https://github.com/tfutils/tfenv) - ```brew install tfenv```
* [pwgen](https://pwgen.io/en/) - ```brew install pwgen```

### Setup

AWS creds need to be setup outside of this repo, a simple way is to use env vars like so (sample file - [.aws_creds](.aws_creds)):

```BASH
# File w/Access Keys
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
export AWS_REGION="eu-west-1"
```

Then you can source this file before running any commands.

### How to Provision Pre-Interview

Before an interview (at least half an hour before) the following actions should be performed:

* Clone this repo
* Setup CLI creds
* Apply production infra - ```make tf-apply```
* Create a user for the candidate - ```make user-generate USERNAME=[USER.NAME]```
* For EKS interviews only, check that the cluster is configured correctly for the candidate:
    * Run `make eks-config` to generate a Kubeconfig
    * Run `kubectl get po -A` - all pods should be running, healthy, and not restarting.

### How to Tear Down Post-Interview

Post interview everything should be taken down:

* **IMPORTANT** for Kubernetes interviews only, run this **before** destroying Terraform:
    * run `make eks-config`
    * run `kubectl delete ingress platform-code-test-app -n default`
* Destroy like so - ```make tf-destroy```
* Remove candidate user - ```make user-delete USERNAME=[USER.NAME]```

### Makefile

A simple [Makefile](Makefile) is provided for running some common commands:

#### Terraform

Use these commands to provision and destroy infrastructure before and after tests:

```BASH
# Plan production before a test
make tf-plan
# Provision production before a test
make tf-apply
# Destroy production before a test
make tf-destroy
```

These commands can be applied to the common env as well:

```BASH
# Run terraform cmds against the common env
make tf-plan ENV=common
make tf-apply ENV=common
```

#### Users

To create and remove a candidate the following commands are available:

```BASH
# Create new user for candidate
make user-generate USERNAME=[USER.NAME]
# Delete user for candidate
make user-delete USERNAME=[USER.NAME]
```

It's also possible to create a new user for interviewers like so:

```BASH
# Create new user for candidate
make user-generate USERNAME=[USER.NAME] INTERVIEWER=1
```
