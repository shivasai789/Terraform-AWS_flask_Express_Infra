terraform {
  backend "s3" {
    bucket         = var.state_bucket          # e.g. “my-tf-state-bucket”
    key            = "${path_relative_to_include()}/terraform.tfstate"
    dynamodb_table = var.state_lock_table      # e.g. “terraform-locks”
    region         = var.aws_region
  }
}
