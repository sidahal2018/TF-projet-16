provider "aws" {
  region = "us-east-1"
}

variable "ec2name" {
  type = string
}

resource "aws_instance" "ec2" {
  ami = "ami-04d29b6f966df1537"
  instance_type = "t2.micro"

  tags = {
     Name = var.ec2name
  }
}