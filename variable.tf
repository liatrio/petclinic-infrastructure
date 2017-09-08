provider "aws" {
  region = "us-west-2"
}

variable "aws_key_pair" {
  default = "terraform-ldop-demo"
}

variable "private_key_path" {
  default = "~/.ssh/id_rsa"
}

# remote state config

terraform {
  backend "s3" {
    bucket = "petclinic-infrastructure-tf-remote-state"
    key    = "petclinic/remote-state"
    region = "us-west-2"
  }
}

data "aws_route53_zone" "liatrio" {
  name = "liatr.io"
}

data "aws_ami" "latest_ami" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  name_regex = "^amzn-ami-hvm-*"
}
