output "repository_url" {
  value = aws_ecr_repository.this.repository_url
}

output "repository_arn" {
  value = aws_ecr_repository.this.arn
}

output "repository_name" {
  value = aws_ecr_repository.this.name
}

output "backend_ecr_repository_url" {
  value = module.ecr_backend.repository_url
}

output "frontend_ecr_repository_url" {
  value = module.ecr_frontend.repository_url
}