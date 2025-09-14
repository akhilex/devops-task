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

# This resource creates the ECR repository.
resource "aws_ecr_repository" "app_repo" {
  name                 = "devops-task-repo"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

# This resource creates the ECS cluster.
resource "aws_ecs_cluster" "app_cluster" {
  name = "devops-task-cluster"
}

# This resource explicitly creates the CloudWatch Log Group for your application logs.
resource "aws_cloudwatch_log_group" "app_log_group" {
  name = "/ecs/devops-task-td"
}

# Look up the latest Amazon Linux 2 AMI that is optimized for ECS.
data "aws_ami" "ecs_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

### --- IAM ROLES FOR EC2 INSTANCE --- ###
# This IAM Role gives the EC2 instance permissions to join the ECS cluster.
resource "aws_iam_role" "ecs_instance_role" {
  name = "ecs-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# This attaches the necessary managed policy to the EC2 IAM role.
resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# An instance profile is a container for the IAM role that the EC2 instance assumes.
resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecs-instance-profile"
  role = aws_iam_role.ecs_instance_role.name
}

### --- IAM ROLE FOR ECS TASK EXECUTION --- ###
# This is a separate role for the ECS tasks themselves to assume.
# It gives them permissions to pull images and publish logs.
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

# Attach the managed policy for the Task Execution Role.
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

### --- EC2 HOST AND NETWORK CONFIGURATION --- ###
# This is a security group for the EC2 instance.
resource "aws_security_group" "ecs_instance_sg" {
  name        = "ecs-instance-sg"
  description = "Allow inbound traffic for ECS container host"
  vpc_id      = "vpc-026b6c01855cee829" 

  ingress {
    from_port   = 3000
    to_port     = 3000
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

# This resource creates a single t2.micro EC2 instance, which is free-tier eligible.
resource "aws_instance" "ecs_host" {
  ami                         = data.aws_ami.ecs_ami.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = "subnet-0aebd6c684bb256d2" 
  vpc_security_group_ids      = [aws_security_group.ecs_instance_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ecs_instance_profile.name
  key_name                    = "jenkins-key"

  user_data = <<-EOF
              #!/bin/bash
              echo ECS_CLUSTER=${aws_ecs_cluster.app_cluster.name} >> /etc/ecs/ecs.config
              sudo yum install -y docker
              sudo service docker start
              sudo usermod -a -G docker ec2-user
              sudo reboot
              EOF
  
  tags = { 
    Name = "ECS Host"
  }
}

### --- ECS TASK AND SERVICE --- ###
# This is the ECS Task Definition.
resource "aws_ecs_task_definition" "app_task_definition" {
  family                   = "devops-task-td"
  requires_compatibilities = ["EC2"]
  network_mode             = "host"
  cpu                      = "256"
  memory                   = "256"
  # This is the correct role for the task to pull images from ECR and send logs to CloudWatch.
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "devops-task-container"
      image     = "${aws_ecr_repository.app_repo.repository_url}:latest"
      cpu       = 256
      memory    = 256
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.app_log_group.name // Reference the new log group
          "awslogs-region"        = "ap-south-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# This is the ECS Service. It ensures that your container runs on the EC2 host.
resource "aws_ecs_service" "app_service" {
  name            = "devops-task-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task_definition.arn
  desired_count   = 1
  launch_type     = "EC2"
}
