# CI/CD Automation on AWS with ECS and Fargate

This repository demonstrates a production-style CI/CD architecture on AWS
for deploying containerized frontend and backend services using
managed AWS services.

The system is fully automated: code changes trigger builds, container
image creation, and zero-downtime deployments to ECS.

## What This Project Shows

- Infrastructure as Code using Terraform
- Automated CI/CD with AWS CodePipeline and CodeBuild
- Containerized frontend and backend services
- Deployment to Amazon ECS with Fargate
- Path-based routing using an Application Load Balancer
- Immutable, rolling deployments with health checks

## High-Level Architecture

```
GitHub
|
v
AWS CodePipeline
|
+---------------------+
|                     |
Build Backend        Build Frontend
(CodeBuild)          (CodeBuild)
|                     |
v                     v
Amazon ECR          Amazon ECR
|                     |
+----------+----------+
|
v
Amazon ECS (Fargate)
├─ Frontend Service
└─ Backend Service
|
v
Application Load Balancer
├─ /       → frontend
└─ /api/*  → backend
```

## Repository Structure

```
app/        # Frontend and backend application code
pipeline/   # CI/CD build and deployment definitions
terraform/  # Infrastructure as Code (AWS resources)
docs/       # Architecture, data flow, and operational docs
```

## Deployment Model

- Containers are built and versioned on every change
- Images are stored in Amazon ECR
- ECS services perform rolling deployments
- Traffic is routed only to healthy tasks
- No manual server or container management

## Documentation

Detailed documentation is available in `docs/`:

- `ARCHITECTURE.md` – system design and components
- `DATAFLOW.md` – runtime and deployment flows
- `DECISIONS.md` – architectural trade-offs
- `RUNBOOK.md` – operational guidance

## Key Principles

- Infrastructure is declarative and version-controlled
- Deployments are immutable
- Services scale independently
- Failures are handled automatically by the platform