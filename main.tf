############################################################
# Terraform + AWS provider setup
############################################################

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

############################################################
# Data sources
############################################################

# Latest Amazon Linux 2023 AMI (x86_64)
data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Default VPC
data "aws_vpc" "default" {
  default = true
}

############################################################
# Security Group (SSH open to world – testing only)
############################################################

resource "aws_security_group" "ec2_sg" {
  name        = "aws-ec2-test-sg"
  description = "Security group for test EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "aws-ec2-test-sg"
    Environment = "test"
    ManagedBy   = "terraform"
  }
}

############################################################
# EC2 Instance
############################################################

resource "aws_instance" "test_ec2" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true

  tags = {
    Name        = "aws-ec2-test-ec2"
    Environment = "test"
    ManagedBy   = "terraform"
  }
}

############################################################
# Random suffix for S3 bucket
############################################################

resource "random_id" "suffix" {
  byte_length = 4
}

############################################################
# S3 Bucket
############################################################

resource "aws_s3_bucket" "test_bucket" {
  bucket        = "aws-ec2-test-bucket-${random_id.suffix.hex}"
  force_destroy = true

  tags = {
    Name        = "aws-ec2-test-s3"
    Environment = "test"
    ManagedBy   = "terraform"
  }
}

############################################################
# Outputs
############################################################

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.test_ec2.id
}

output "public_ip" {
  description = "EC2 public IP"
  value       = aws_instance.test_ec2.public_ip
}

output "public_dns" {
  description = "EC2 public DNS"
  value       = aws_instance.test_ec2.public_dns
}

output "bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.test_bucket.bucket
}
