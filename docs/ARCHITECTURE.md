# Architecture

## Overview
This project implements a CI/CD pipeline on AWS that builds, containerizes, and deploys a Spring Boot application using managed AWS services.

The system is designed to be:
- Fully automated on code change
- Container-based
- Minimal operational overhead

## High-Level Architecture

```
Developer
|
|  (git push)
v
GitHub Repository
|
|  Source stage
v
AWS CodePipeline
|
|  Build stage
v
AWS CodeBuild
|
|  docker build + push
v
Amazon ECR (Container Registry)
|
|  image pull
v
Amazon ECS (Fargate)
|
|  running tasks
v
Application Load Balancer
|
v
End Users
```

## Core Components and Responsibilities

### GitHub
- Source of truth for application code, pipeline config, and infrastructure code.

### AWS CodePipeline
- Orchestrates the CI/CD workflow.
- Triggers automatically on changes to the GitHub repository.

### AWS CodeBuild
- Executes build instructions defined in `buildspec.yml`.
- Builds Docker image.
- Pushes image to Amazon ECR.

### Amazon ECR
- Stores versioned Docker images.
- Acts as the deployment artifact source for ECS.

### Amazon ECS (Fargate)
- Runs containers without managing servers.
- Pulls images from ECR.
- Replaces running tasks during deployments.

### Application Load Balancer
- Routes HTTP traffic to ECS tasks.
- Provides a stable endpoint for users.

## Infrastructure Boundary

```
terraform/   -> defines AWS resources
pipeline/    -> consumed by AWS services
app/         -> application source code
docs/        -> system documentation
```

Terraform owns **resource creation**.  
Pipeline files define **runtime behavior**.  
Application code remains **infra-agnostic**.

## Deployment Model
- Rolling update via ECS service.
- No in-place server modification.
- Old tasks are replaced by new task revisions.