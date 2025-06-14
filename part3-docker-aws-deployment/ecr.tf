resource "aws_ecr_repository" "backend" {
  name                 = "shivasai789-docker-assignment-backend"  # Cleaned name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    GitHub-Repo = "https://github.com/shivasai789/docker-assignment/tree/master/backend"
  }
}

resource "aws_ecr_repository" "frontend" {
  name                 = "shivasai789-docker-assignment-frontend"  # Cleaned name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    GitHub-Repo = "https://github.com/shivasai789/docker-assignment/tree/master/frontend"
  }
}