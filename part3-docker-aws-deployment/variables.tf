variable "aws_region" {
  description = "AWS region"
  default     = "ap-south-1"
}

variable "app_name" {
  description = "Application name"
  default     = "fullstack-app"
}

variable "environment" {
  description = "Deployment environment"
  default     = "production"
}

variable "backend_desired_count" {
  description = "Number of backend tasks to run"
  default     = 1
}

variable "frontend_desired_count" {
  description = "Number of frontend tasks to run"
  default     = 1
}

variable "mongo_uri" {
  description = "MongoDB connection string"
  type        = string
  sensitive   = true
  default = "mongodb+srv://mamidalashivasai789:cBGXtoae0yjhEmTJ@cluster0.eraiyey.mongodb.net/"
}