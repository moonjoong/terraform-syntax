terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.39.1"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-east-1"
}

# Create a VPC
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}
