provider "aws" {
  region = "us-east-1"
}
resource "aws_instance" "insatance" {
  ami           = "ami-00beae93a2d981137"
  instance_type = "t2.micro"
  key_name      = "jenkins-key-1"
  tags = {
    Name = "terraformins"
  }
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
  EOF
}
resource "aws_s3_bucket" "s3_bucket" {
    bucket = "s3-terraformins-bup"
    acl = "private"
}
resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name = "terraform-dynamo-1"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20
  attribute {
    name = "LockID"
    type = "S"
  }
}
terraform {
  backend "s3" {
    bucket = "s3-terraformins-bup"
    dynamodb_table = "terraform-dynamo-1"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

