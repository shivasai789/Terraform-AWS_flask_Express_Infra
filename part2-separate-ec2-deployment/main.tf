terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Networking
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"  # Fixed from "0.0.0.0/0" to valid CIDR
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name        = "FullStack-VPC"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags = {
    Name        = "Public-Subnet"
    Environment = "production"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name        = "Main-IGW"
    Environment = "production"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name        = "Public-RouteTable"
    Environment = "production"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Groups with Improved Rules
resource "aws_security_group" "backend_sg" {
  name        = "backend-sg"
  description = "Security group for Flask backend"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "backend-sg"
    Environment = "production"
    ManagedBy   = "terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "frontend_sg" {
  name        = "frontend-sg"
  description = "Security group for Express frontend"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "frontend-sg"
    Environment = "production"
    ManagedBy   = "terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Backend Security Group Rules
resource "aws_security_group_rule" "backend_ssh" {
  security_group_id = aws_security_group.backend_sg.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.ssh_access_cidr] # Use variable for restricted IP
}

resource "aws_security_group_rule" "backend_flask" {
  security_group_id        = aws_security_group.backend_sg.id
  type                     = "ingress"
  from_port                = 5000
  to_port                  = 5000
  protocol                 = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]  # Use SG reference instead of IP
}

resource "aws_security_group_rule" "backend_health_check" {
  security_group_id = aws_security_group.backend_sg.id
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.main.cidr_block] # Only from within VPC
}

resource "aws_security_group_rule" "backend_egress" {
  security_group_id = aws_security_group.backend_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  
  # Add lifecycle to ignore changes to this rule
  lifecycle {
    create_before_destroy = true
  }
}

# Frontend Security Group Rules
resource "aws_security_group_rule" "frontend_ssh" {
  security_group_id = aws_security_group.frontend_sg.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.ssh_access_cidr] # Use variable for restricted IP
}

resource "aws_security_group_rule" "frontend_http" {
  security_group_id = aws_security_group.frontend_sg.id
  type              = "ingress"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "frontend_to_backend" {
  security_group_id        = aws_security_group.frontend_sg.id
  type                     = "egress"
  from_port                = 5000
  to_port                  = 5000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.backend_sg.id
}

resource "aws_security_group_rule" "frontend_egress_http" {
  security_group_id = aws_security_group.frontend_sg.id
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "frontend_egress_https" {
  security_group_id = aws_security_group.frontend_sg.id
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

# EC2 Instances
resource "aws_instance" "backend" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  user_data              = file("${path.module}/backend-user-data.sh")

  tags = {
    Name        = "Flask-Backend"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

resource "aws_instance" "frontend" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.frontend_sg.id]
  user_data              = templatefile("${path.module}/frontend-user-data.sh", {
    backend_url = "http://${aws_instance.backend.private_ip}:5000"
  })

  tags = {
    Name        = "Express-Frontend"
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  depends_on = [aws_instance.backend]
}

# Key Pair
resource "aws_key_pair" "deployer" {
  key_name   = "fullstack-deployer-key-${var.environment}"
  public_key = file("~/.ssh/id_rsa.pub")

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# AMI Data Source
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}