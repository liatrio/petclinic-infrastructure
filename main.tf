provider "aws" {
  region = "us-west-2"
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
