variable "role_arn" {}
variable "artifact_bucket" {}
variable "github_owner" {}
variable "github_repo" {}
variable "github_branch" {}
variable "github_token" {}
variable "codebuild_project_name" {}

variable "ecs_cluster_name" {
  type = string
}

variable "ecs_service_name" {
  type = string
}