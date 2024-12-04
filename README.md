# platform-code-test

A live coding to test for potential platform engineers.

## Usage

### Requirements

* [tfenv](https://github.com/tfutils/tfenv) - ```brew install tfenv```

### Setup

* Add credentials to [.aws_creds](/.aws_creds) and source in your shell environment
* Update the [INTERVIEW_TYPE](./INTERVIEW_TYPE) file to reflect the flavour of interview (ECS or EKS), by removing the comment on the relevant line

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
