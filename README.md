# CI/CD Automation on AWS

This project implements a fully automated CI/CD pipeline on AWS to build, containerize, and deploy a Spring Boot application using managed AWS services.

## What This Project Does
- Triggers a pipeline on GitHub code changes
- Builds a Docker image using AWS CodeBuild
- Pushes the image to Amazon ECR
- Deploys the image to Amazon ECS (Fargate)
- Serves traffic through an Application Load Balancer

## Technology Stack
- AWS CodePipeline
- AWS CodeBuild
- Amazon ECR
- Amazon ECS (Fargate)
- Application Load Balancer
- Terraform
- Docker
- Spring Boot

## Repository Structure

```
app/        -> Application source code
pipeline/   -> CI/CD configuration files
terraform/  -> Infrastructure as code
docs/       -> Architecture and data flow documentation
```

## Documentation
- `docs/ARCHITECTURE.md` – System architecture
- `docs/DATAFLOW.md` – CI/CD and runtime flow
- `docs/DECISIONS.md` – Architectural decisions
- `docs/RUNBOOK.md` – Operational notes

## Deployment Overview
1. Push code to GitHub
2. CodePipeline triggers automatically
3. CodeBuild builds and pushes Docker image
4. ECS service deploys updated container

## Notes
This project focuses on automation, clarity, and managed services rather than manual server configuration.