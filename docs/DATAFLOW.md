# Data Flow

This document describes how data flows through the system at runtime and during deployments.

## Runtime Request Flow (User → Application)

```

User Browser
|
v
Application Load Balancer (ALB)
|
|  Path-based routing
|
+--> "/"       → Frontend ECS Service
|
+--> "/api/*"  → Backend ECS Service

```

### Runtime behavior
- The ALB is the single public entry point.
- Frontend serves the UI.
- Frontend calls backend APIs via `/api/*`.
- Backend processes requests and returns JSON responses.
- ECS services scale independently.

## CI/CD Deployment Flow (Code → Production)

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
| docker build        | docker build
| docker push         | docker push
v                     v
Amazon ECR          Amazon ECR
|                     |
+----------+----------+
|
v
Amazon ECS
|
| new task revision
v
ECS Service (rolling update)
```

### Deployment behavior
- Each service is built independently.
- New images are pushed to ECR.
- ECS pulls the new image.
- Old tasks are drained.
- New tasks must pass ALB health checks before traffic is shifted.

## Failure Handling

```
Health Check Fails
|
v
ECS Stops New Task
|
v
Deployment Rolls Back
```

- Traffic is never routed to unhealthy containers.
- Previous task revision continues serving requests.

## Key Principles

- Immutable deployments
- No SSH or manual intervention
- Infrastructure remains unchanged during app updates
- Build, release, and runtime concerns are separated