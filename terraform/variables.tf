# Input variables will be defined here

variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources into"
  default     = "us-east-2"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to the local SSH public key used for EC2 access"
  default     = "~/.ssh/deploy-multi-tier.pub"
}

variable "github_repo_url" {
  type = string
}

variable "github_owner" {
  type        = string
  description = "GitHub organization or username"
}

variable "github_repo" {
  type        = string
  description = "GitHub repository name"
}

variable "github_branch" {
  type    = string
  default = "main"
}

variable "github_token" {
  type        = string
  sensitive   = true
  description = "GitHub OAuth token"
}

variable "artifact_bucket" {
  type        = string
  description = "S3 bucket for CodePipeline artifacts"
}
