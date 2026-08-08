terraform {
    required_version ">= 1.0.0"

    required_providers {
        aws = {
            source = "hashcorp/aws"
            version = "~> 5.0"
        }
    }
}

provider "aws" {
    region = "us-east-1"
}

data "aws_ami" "ubuntu" {
    most_recent = true
    owners = ["099720109477"] # owner indica que é a canonical

    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }
}

resource "aws_vpc" "main" {
    cidr_block = "192.168.10.0/24"
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
        Name = "vpc-aula-terraform"
    }
}