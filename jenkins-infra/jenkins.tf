# This block tells Terraform what cloud provider to use (AWS) and the region.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# This is the provider configuration block.
provider "aws" {
  region = "ap-south-1" 
}

### --- JENKINS INFRASTRUCTURE --- ###
data "aws_ami" "jenkins_ami" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow inbound traffic for Jenkins server"
  vpc_id      = "vpc-026b6c01855cee829"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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
}

resource "aws_instance" "jenkins_server" {
  ami           = data.aws_ami.jenkins_ami.id
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id     = "subnet-0aebd6c684bb256d2"
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  key_name = "jenkins-key"

  user_data = <<-EOF
            #!/bin/bash
            sudo apt-get update -y
            sudo apt-get install openjdk-17-jre -y  
            curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
            echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
            sudo apt-get update -y
            sudo apt-get install jenkins -y
            sudo systemctl start jenkins
            EOF

  tags = {
    Name = "Jenkins Server"
  }
}