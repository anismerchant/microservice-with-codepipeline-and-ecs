# Architecture

## Overview

This project implements a **fully automated CI/CD architecture on AWS** for a **microservices-style application** consisting of:

* **Backend API** (containerized service)
* **Frontend UI** (containerized service)

Both services are built, containerized, and deployed automatically using managed AWS services.
Infrastructure is defined using **Terraform** and remains stable while application services evolve independently.

Goals:

* Zero manual deployments
* Clear separation of concerns
* Production-grade AWS patterns
* Minimal operational overhead

## High-Level Architecture

```
Developer
  |
  | git push
  v
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
(backend repo)      (frontend repo)
  |                     |
  +----------+----------+
             |
             v
        Amazon ECS (Fargate)
        ├─ Backend Service
        └─ Frontend Service
             |
             v
      Application Load Balancer
      ├─ /api/* → backend
      └─ /       → frontend
             |
             v
          End Users
```

## Core Components and Responsibilities

### GitHub

* Source of truth for:

  * Application code (`app/`)
  * Pipeline definitions (`pipeline/`)
  * Infrastructure as Code (`terraform/`)
* Any push triggers the CI/CD workflow.

### AWS CodePipeline

* Orchestrates the end-to-end CI/CD process.
* Stages:

  * **Source** (GitHub)
  * **Build** (parallel backend + frontend builds)
  * **Deploy** (ECS)

### AWS CodeBuild

* Builds Docker images using service-specific buildspec files:

  * `backend-buildspec.yml`
  * `frontend-buildspec.yml`
* Responsibilities:

  * Compile application code
  * Build Docker images
  * Push images to Amazon ECR
  * Generate deployment metadata for ECS

### Amazon ECR

* Stores versioned container images.
* Separate repositories per service:

  * Backend image repository
  * Frontend image repository

### Amazon ECS (Fargate)

* Runs containers without managing servers.
* Each service has:

  * Its own task definition
  * Its own ECS service
* Handles rolling deployments automatically.

### Application Load Balancer (ALB)

* Public entry point for the system.
* Routes traffic using path-based rules:

  * `/` → frontend service
  * `/api/*` → backend service
* Performs health checks on ECS tasks.

## Infrastructure Ownership Boundaries

```
terraform/   → AWS resources (VPC, ALB, ECS, IAM, ECR, pipelines)
pipeline/    → CI/CD behavior (buildspecs, deployment specs)
app/         → Application code (frontend + backend)
docs/        → System documentation
```

Key principle:

> **Terraform owns infrastructure.
> Pipelines own delivery.
> Applications remain infra-agnostic.**

## Deployment Model

* Immutable deployments using ECS task revisions
* Rolling updates with health checks
* No in-place server changes
* Automatic rollback on failure (via ECS service stability)

## Architecture Characteristics

* Fully automated CI/CD
* Horizontally scalable
* Service isolation
* Production-aligned AWS patterns
* Clean separation between infrastructure and application code