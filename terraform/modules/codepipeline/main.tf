resource "aws_codepipeline" "this" {
  name     = "microservices-with-codepipeline-and-ecs"
  role_arn = var.role_arn

  artifact_store {
    location = var.artifact_bucket
    type     = "S3"
  }

  ############################
  # Source
  ############################

  stage {
    name = "Source"

    action {
      name             = "GitHub_Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = var.github_owner
        Repo       = var.github_repo
        Branch     = var.github_branch
        OAuthToken = var.github_token
      }
    }
  }

  ############################
  # Build (parallel)
  ############################

  stage {
    name = "Build"

    action {
      name             = "Build_Backend"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["backend_build_output"]

      configuration = {
        ProjectName = var.codebuild_backend_project_name
      }
    }

    action {
      name             = "Build_Frontend"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["frontend_build_output"]

      configuration = {
        ProjectName = var.codebuild_frontend_project_name
      }
    }
  }

  ############################
  # Deploy
  ############################

  stage {
    name = "Deploy"

    action {
      name            = "Deploy_Backend"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = "1"
      input_artifacts = ["backend_build_output"]

      configuration = {
        ClusterName = var.ecs_cluster_name
        ServiceName = var.ecs_backend_service_name
        FileName    = "imagedefinitions.json"
      }
    }

    action {
      name            = "Deploy_Frontend"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = "1"
      input_artifacts = ["frontend_build_output"]

      configuration = {
        ClusterName = var.ecs_cluster_name
        ServiceName = var.ecs_frontend_service_name
        FileName    = "imagedefinitions.json"
      }
    }
  }
}
