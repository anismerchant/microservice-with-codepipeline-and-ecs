variable "artifact_bucket_arn" {
  type = string
}

variable "ecr_repository_arns" {
  type = list(string)
}

variable "ecs_execution_role_arn" {
  type = string
}
