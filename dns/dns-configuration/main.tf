terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_key_pair" "ec2_user" {
  key_name   = "operator-ssh-key"
  public_key = "pubkey here"
}

resource "aws_instance" "dns_project" {
  for_each = toset(["client", "ns1", "ns2", "cache-only-server"])
  # Amazon Linux 2023
  ami             = "ami-05dc908211c15c11d"
  instance_type   = "t2.micro"
  security_groups = ["default", "launch-wizard-2"]
  tags = {
    Name = each.key
  }
  user_data = <<-EOF
	#!/bin/bash
	hostnamectl set-hostname ${each.key}
	EOF
  instance_market_options {
    market_type = "spot"
    spot_options {
      instance_interruption_behavior = "stop"
      spot_instance_type             = "persistent"
      valid_until                    = "2023-12-21T00:00:00Z"
    }
  }
  key_name = aws_key_pair.ec2_user.id
}

output "instance_public_ip" {
  value = {
    for k, v in aws_instance.dns_project : k => { public_ip = v.public_ip, private_ip = v.private_ip }
  }
}
