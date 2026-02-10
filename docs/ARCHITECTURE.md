# Architecture

## Overview

This project implements a **fully automated CI/CD architecture on AWS** for a **microservices-style application** consisting of:

- **Backend API** (containerized service)
- **Frontend UI** (containerized service)

Both services are built, containerized, and deployed automatically using managed AWS services.
Infrastructure is defined using **Terraform** and remains stable while application services evolve independently.

Goals:

- Zero manual deployments
- Clear separation of concerns
- Production-grade AWS patterns
- Minimal operational overhead

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

- Source of truth for:
  - Application code (`app/`)
  - Pipeline definitions (`pipeline/`)
  - Infrastructure as Code (`terraform/`)

- Any push triggers the CI/CD workflow.

### AWS CodePipeline

- Orchestrates the end-to-end CI/CD process.
- Stages:
  - **Source** (GitHub)
  - **Build** (parallel backend + frontend builds)
  - **Deploy** (ECS)

### AWS CodeBuild

- Builds Docker images using service-specific buildspec files:
  - `backend-buildspec.yml`
  - `frontend-buildspec.yml`

- Responsibilities:
  - Compile application code
  - Build Docker images
  - Push images to Amazon ECR
  - Generate deployment metadata for ECS

### Amazon ECR

- Stores versioned container images.
- Separate repositories per service:
  - Backend image repository
  - Frontend image repository

### Amazon ECS (Fargate)

- Runs containers without managing servers.
- Each service has:
  - Its own task definition
  - Its own ECS service

- Handles rolling deployments automatically.

### Application Load Balancer (ALB)

- Public entry point for the system.
- Routes traffic using path-based rules:
  - `/` → frontend service
  - `/api/*` → backend service

- Performs health checks on ECS tasks.

## Service and Container Model

**Each service = a logical service backed by many containers.**

Not one container.
Not a cluster by itself.
A **service is a managed group of identical containers.**

## What “service” means in _this_ architecture (ECS terms)

```
ECS Cluster
  |
  +-- ECS Service: frontend
  |     |
  |     +-- Task (container)  ← running copy
  |     +-- Task (container)
  |     +-- Task (container)
  |
  +-- ECS Service: backend
        |
        +-- Task (container)
        +-- Task (container)
```

### Definitions (keep these straight)

- **Container**
  A single running Docker instance.

- **Task Definition**
  Blueprint for how a container runs (image, port, env vars).

- **Task**
  A running instance of a task definition (one or more containers).

- **ECS Service**
  Ensures _N copies_ of a task are always running.
  Handles:
  - scaling
  - rolling deployments
  - health checks
  - restarts

- **ECS Cluster**
  A logical pool where services run (Fargate capacity).

- **Frontend service**
  - One task definition
  - One container per task
  - Multiple running tasks for availability

- **Backend service**
  - One task definition
  - One container per task
  - Multiple running tasks for availability

> A service = **a scalable group of containers that collectively represent the frontend or backend**

## Why this matters (architectural reason)

If it were _one container_:

- No redundancy
- No rolling deploys
- No health-based replacement

If it were _one big container for everything_:

- Tight coupling
- No independent scaling
- Slower deployments

ECS Service gives you:

- High availability
- Zero-downtime deploys
- Independent scaling per service

## Mental shortcut (remember this)

- Container runs code.
- Service runs containers correctly.
- Cluster runs services.

## Why you see **one EC2** even though you’re using Fargate

### Short answer

- That EC2 is not yours.
- It is not part of your architecture.
- You do not depend on it.

When using **ECS with Fargate**:

- AWS still runs containers on physical servers
- Those servers are abstracted away
- Sometimes the console surfaces **one underlying host** for visibility
- **It is not a single point of failure**

You cannot:

- SSH into it
- Scale it
- Patch it
- Rely on it

AWS can move your tasks to **entirely different machines** at any time.

> Seeing “one EC2” does **not** mean your system runs on one server.

## What _actually_ provides availability in Fargate

Availability comes from:

- **Multiple tasks**
- **Multiple Availability Zones**
- **ALB health checks**
- **ECS service reconciliation**

```
ALB
 |
 +-- AZ-A
 |     +-- Fargate Task (frontend)
 |     +-- Fargate Task (backend)
 |
 +-- AZ-B
       +-- Fargate Task (frontend)
       +-- Fargate Task (backend)
```

If hardware dies:

- Task stops
- ECS replaces it
- Traffic never reaches unhealthy tasks

## Failure Model and Availability

This system is designed with the assumption that underlying compute
can and will fail.

### ECS with Fargate

When using ECS with Fargate, there are no EC2 instances managed by the user.

- AWS owns and operates the underlying servers
- Tasks are scheduled across multiple Availability Zones
- If underlying hardware fails, tasks are automatically restarted
- The Application Load Balancer routes traffic only to healthy tasks

Although the AWS console may display a single underlying host, this host is **not part of the system architecture** and does not represent
a single point of failure.

Availability is achieved through:

- Multiple running tasks per service
- ECS service reconciliation
- ALB health checks
- Multi–Availability Zone placement

### ECS Service Behavior on Failure

```
Task or Host Failure
|
v
ECS Detects Failure
|
v
New Task Launched
|
v
ALB Routes Traffic to Healthy Tasks Only
```

No manual intervention is required, and users do not experience downtime.

## Infrastructure Ownership Boundaries

```
terraform/   → AWS resources (VPC, ALB, ECS, IAM, ECR, pipelines)
pipeline/    → CI/CD behavior (buildspecs, deployment specs)
app/         → Application code (frontend + backend)
docs/        → System documentation
```

Key principle:

- Terraform owns infrastructure.
- Pipelines own delivery.
- Applications remain infra-agnostic.

## Deployment Model

- Immutable deployments using ECS task revisions
- Rolling updates with health checks
- No in-place server changes
- Automatic rollback on failure (via ECS service stability)

## Architecture Characteristics

- Fully automated CI/CD
- Horizontally scalable
- Service isolation
- Production-aligned AWS patterns
- Clean separation between infrastructure and application code
