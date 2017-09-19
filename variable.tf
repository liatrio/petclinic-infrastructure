variable "aws_key_pair" {
  default = "terraform-ldop-demo"
}

variable "private_key_path" {
  default = "~/.ssh/id_rsa"
}

variable "ami" {
  default = "ami-bb9e6ec3" # amazon linux us-west-2
}
