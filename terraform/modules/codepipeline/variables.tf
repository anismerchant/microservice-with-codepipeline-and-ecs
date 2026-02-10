variable "role_arn" {}
variable "artifact_bucket" {}

variable "github_owner" {}
variable "github_repo" {}
variable "github_branch" {}
variable "github_token" {}

variable "codebuild_backend_project_name" {
  type = string
}

variable "codebuild_frontend_project_name" {
  type = string
}

variable "ecs_cluster_name" {
  type = string
}

variable "ecs_backend_service_name" {
  type = string
}

variable "ecs_frontend_service_name" {
  type = string
}
