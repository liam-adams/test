module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  version         = "1.6.0"
  repository_name = var.ecr_repo

  repository_read_write_access_arns = [module.eks.cluster_iam_role_arn]
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}
