# aws-ec2-test

Simple Terraform repo to create a test EC2 instance in AWS.

## Prerequisites

- Terraform >= 1.5
- AWS CLI configured (`aws configure` or `AWS_PROFILE`)
- IAM user/role with permissions:
  - `ec2:*` on instances, security groups, AMIs, subnets (for testing)
  - `vpc:Describe*`

## Usage

```bash
terraform init
terraform plan
terraform apply