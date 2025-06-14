variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "Instance type for EC2"
  default     = "t2.micro"
}
variable "access_key"{
}

variable "secret_key"{
}