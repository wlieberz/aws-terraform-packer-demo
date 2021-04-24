#!/usr/bin/env bash

# Very simple shell script demonstrating the minimum steps needed to bring up the project.
# Assumes you have packer and terraform installed already and have aws authentication configured.

# Build custom AMI:
cd packer
packer build front-end-server.pkr.hcl

# Bring up infra with terraform:
cd ../terraform/
terraform init
terraform apply -auto-approve

# Sanity check application is running:
echo "You can sanity check that the project is running by visiting the DNS name of the elb output, above."