# platform-code-test

A live coding to test for potential platform engineers.

## Requirements

* [docker](https://www.docker.com/)

## Setup

AWS creds need to be setup outside of this repo, a simple way is to use env 
vars like so (sample file - [.env](.env)):

```BASH
# File w/Access Keys
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
export AWS_REGION="eu-west-1"
```

### S3 State Bucket

An S3 bucket is required to store state in, this must be created manually, please see the provider files ([here](terraform/environments/common/providers.tf) and [here](terraform/environments/production/providers.tf)) for the bucket name.

## Usage

A simple [Makefile](Makefile) is provided for running some common commands:

```BASH
# Run init and plan
make

# Run terraform plan, runs against production by default
make plan

# Run terraform apply
make apply

# Run terraform cmds against the common env
make plan ENV=common
make apply ENV=common

# Destroy production post interview
make destroy
```

## Environments

### Production

This is where the candidate will be working during the test, it should be destroyed and recreated between tests.

### Common

This contains resources that should persist between tests, will need to be applied before the production env
