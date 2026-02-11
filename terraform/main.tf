provider "aws" {
  region = var.aws_region
}

############################
# Network & Compute
############################

module "network" {
  source     = "./modules/network"
  aws_region = var.aws_region
}

module "compute" {
  source              = "./modules/compute"
  subnet_id           = module.network.public_subnet_id
  security_group_id   = module.network.ssh_sg_id
  ssh_public_key_path = var.ssh_public_key_path
}

############################
# ECR
############################

module "ecr_backend" {
  source          = "./modules/ecr"
  repository_name = "backend"
}

module "ecr_frontend" {
  source          = "./modules/ecr"
  repository_name = "frontend"
}

############################
# Artifact Bucket
############################

module "artifact_bucket" {
  source      = "./modules/s3"
  bucket_name = var.artifact_bucket
}

############################
# IAM
############################

module "iam" {
  source = "./modules/iam"

  artifact_bucket_arn = module.artifact_bucket.bucket_arn
  ecr_repository_arns = [
    module.ecr_backend.repository_arn,
    module.ecr_frontend.repository_arn
  ]
  ecs_execution_role_arn = module.iam.ecs_execution_role_arn
}

############################
# ALB
############################

module "alb" {
  source     = "./modules/alb"
  vpc_id     = module.network.vpc_id
  subnet_ids = module.network.public_subnet_ids
}

############################
# ECS Services
############################

module "ecs_backend" {
  source             = "./modules/ecs"
  aws_region         = var.aws_region
  execution_role_arn = module.iam.ecs_execution_role_arn
  image_uri          = "${module.ecr_backend.repository_url}:latest"
  subnet_ids         = module.network.public_subnet_ids
  service_sg_id      = module.network.ssh_sg_id
  target_group_arn   = module.alb.backend_target_group_arn
  alb_listener_dep   = module.alb
  vpc_id             = module.network.vpc_id
  alb_sg_id          = module.alb.alb_sg_id

  service_name   = "backend"
  container_port = 8080
}

module "ecs_frontend" {
  source             = "./modules/ecs"
  aws_region         = var.aws_region
  execution_role_arn = module.iam.ecs_execution_role_arn
  image_uri          = "${module.ecr_frontend.repository_url}:latest"
  subnet_ids         = module.network.public_subnet_ids
  service_sg_id      = module.network.ssh_sg_id
  target_group_arn   = module.alb.frontend_target_group_arn
  alb_listener_dep   = module.alb
  vpc_id             = module.network.vpc_id
  alb_sg_id          = module.alb.alb_sg_id

  service_name   = "frontend"
  container_port = 80
}

############################
# CodeBuild
############################

module "codebuild_backend" {
  source          = "./modules/codebuild"
  role_arn        = module.iam.codebuild_role_arn
  project_name    = "backend-build"
  buildspec_path  = "pipeline/backend-buildspec.yml"
  ecr_repo_url    = module.ecr_backend.repository_url
  github_repo_url = var.github_repo_url
}

module "codebuild_frontend" {
  source          = "./modules/codebuild"
  role_arn        = module.iam.codebuild_role_arn
  project_name    = "frontend-build"
  buildspec_path  = "pipeline/frontend-buildspec.yml"
  ecr_repo_url    = module.ecr_frontend.repository_url
  github_repo_url = var.github_repo_url
}

############################
# CodePipeline (backend only for now)
############################

module "codepipeline" {
  source          = "./modules/codepipeline"
  role_arn        = module.iam.codepipeline_role_arn
  artifact_bucket = module.artifact_bucket.bucket_name

  github_owner  = var.github_owner
  github_repo   = var.github_repo
  github_branch = "main"
  github_token  = var.github_token

  codebuild_backend_project_name  = module.codebuild_backend.project_name
  codebuild_frontend_project_name = module.codebuild_frontend.project_name

  ecs_cluster_name          = module.ecs_backend.cluster_name
  ecs_backend_service_name  = module.ecs_backend.service_name
  ecs_frontend_service_name = module.ecs_frontend.service_name
}
