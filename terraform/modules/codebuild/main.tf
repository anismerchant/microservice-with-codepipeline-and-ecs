resource "aws_codebuild_project" "this" {
  name          = "cicd-automation-build"
  service_role = var.role_arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true

    environment_variable {
      name  = "ECR_REPO"
      value = var.ecr_repo_url
    }
  }

  source {
    type      = "GITHUB"
    location  = var.github_repo_url
    buildspec = "pipeline/buildspec.yml"
  }
}
