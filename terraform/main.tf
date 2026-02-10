provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "./modules/network"
  aws_region = var.aws_region
}

module "compute" {
  source              = "./modules/compute"
  subnet_id           = module.network.public_subnet_id
  security_group_id   = module.network.ssh_sg_id
  ssh_public_key_path = var.ssh_public_key_path
}

module "ecr" {
  source           = "./modules/ecr"
  repository_name  = "cicd-automation-app"
}

module "iam" {
  source = "./modules/iam"

  artifact_bucket_arn = module.artifact_bucket.bucket_arn
  ecr_repository_arn = module.ecr.repository_arn
  ecs_execution_role_arn = module.iam.ecs_execution_role_arn
}

module "ecs" {
  source               = "./modules/ecs"
  aws_region            = var.aws_region
  execution_role_arn   = module.iam.ecs_execution_role_arn
  image_uri            = "${module.ecr.repository_url}:latest"
  subnet_ids           = module.network.public_subnet_ids
  service_sg_id        = module.network.ssh_sg_id
  target_group_arn     = module.alb.target_group_arn
  alb_listener_dep     = module.alb
  vpc_id              = module.network.vpc_id
  alb_sg_id           = module.alb.alb_sg_id
}

module "alb" {
  source             = "./modules/alb"
  vpc_id             = module.network.vpc_id
  subnet_ids         = module.network.public_subnet_ids
}

module "codebuild" {
  source          = "./modules/codebuild"
  role_arn        = module.iam.codebuild_role_arn
  ecr_repo_url    = module.ecr.repository_url
  github_repo_url = var.github_repo_url
}

module "codepipeline" {
  source                     = "./modules/codepipeline"
  role_arn                   = module.iam.codepipeline_role_arn
  artifact_bucket             = module.artifact_bucket.bucket_name
  github_owner                = var.github_owner
  github_repo                 = var.github_repo
  github_branch               = "main"
  github_token                = var.github_token
  codebuild_project_name      = module.codebuild.project_name

  ecs_cluster_name = module.ecs.cluster_name
  ecs_service_name = module.ecs.service_name

}

module "artifact_bucket" {
  source      = "./modules/s3"
  bucket_name = var.artifact_bucket
}
