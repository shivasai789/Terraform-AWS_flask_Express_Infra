variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "Instance type for EC2"
  default     = "t2.micro"
}

variable "ssh_access_cidr" {
  description = "CIDR block for SSH access"
  type        = string
  default     = "0.0.0.0/0" # Change this to your IP for production
}

variable "environment" {
  description = "Deployment environment (dev/stage/prod)"
  type        = string
  default     = "dev"
}

variable "backend_port" {
  description = "Port for Flask backend"
  default     = 5000
}

variable "frontend_port" {
  description = "Port for Express frontend"
  default     = 3000
}