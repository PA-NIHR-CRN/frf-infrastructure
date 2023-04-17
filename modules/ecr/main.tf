resource "aws_ecr_repository" "repo" {
  name                 = var.repo_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Environment = var.env
    Name        = var.repo_name
    System      = "nsip"
  }
  lifecycle {
    ignore_changes = [
      tags,
      tags_all
    ]
  }
}