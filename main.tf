terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_instance" "app_server" {
  ami                    = "ami-06672d07f62285d1d"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.tech-challenge-sg.id]
  key_name               = "tech_challange"

  tags = {
    Name = "mrw-tech-challenge-server"
  }
  user_data = file("user-data.sh")
}

resource "aws_security_group" "tech-challenge-sg" {
  name = "tech-challenge-sg"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["82.17.168.125/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

