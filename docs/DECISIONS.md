# Architectural Decisions

This document records the major architectural decisions and the reasoning behind them.

## Use ECS with Fargate

**Decision:** Deploy containers using Amazon ECS with Fargate.

**Why:**
- No server management or patching
- Built-in high availability
- Automatic task replacement on failure
- Cleaner operational model than ECS on EC2

## Separate Frontend and Backend Services

**Decision:** Run frontend and backend as independent ECS services.

**Why:**
- Independent scaling
- Independent deployments
- Clear separation of concerns
- Reduced blast radius during failures

## Path-Based Routing via Application Load Balancer

**Decision:** Use a single ALB with path-based routing.

```
/       → frontend service
/api/*  → backend service
```

**Why:**
- Single public entry point
- Simple client-side integration
- No need for separate domains
- Common production pattern

## Parallel Builds in CI/CD

**Decision:** Build frontend and backend images in parallel.

**Why:**
- Faster pipelines
- Clear ownership per service
- Failures are isolated to the affected service

## Immutable Deployments

**Decision:** Use immutable container deployments via ECS task revisions.

**Why:**
- No in-place changes
- Easy rollback
- Predictable deployments
- Matches cloud-native best practices

## Infrastructure as Code with Terraform

**Decision:** Define all infrastructure using Terraform modules.

**Why:**
- Reproducibility
- Clear resource ownership
- Safe incremental changes
- Easy review and rollback