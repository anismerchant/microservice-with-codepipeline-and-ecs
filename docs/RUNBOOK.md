# Runbook

This document describes how to operate, observe, and troubleshoot the system.

## Normal Operation

- Deployments are fully automated via CI/CD.
- No manual container restarts or server access is required.
- ECS services maintain desired task count automatically.

## Deploying a Change

```
git push
|
v
CodePipeline → CodeBuild → ECR → ECS
```

Expected result:
- New task revision created
- Old tasks drained
- New tasks pass health checks
- Traffic shifts automatically

## Health Checks

- Health checks are performed by the Application Load Balancer.
- Unhealthy tasks never receive traffic.
- ECS replaces failed tasks automatically.

## Monitoring

Primary signals:
- **CodePipeline**: build or deploy failures
- **ECS Service Events**: task restarts, deployment status
- **CloudWatch Logs**: application logs per container

## Common Failure Scenarios

### Build Failure
- Cause: Docker build error or test failure
- Action: Check CodeBuild logs

### Deployment Stuck
- Cause: Health checks failing
- Action:
  - Verify container port
  - Verify ALB target group health check path
  - Check application startup logs

### Task Keeps Restarting
- Cause: Application crash or misconfiguration
- Action: Inspect CloudWatch logs for the task

## Rollback

- ECS automatically keeps previous task revisions.
- Rolling back means redeploying the last known good image.
- No infrastructure changes are required.

## What Not To Do

- Do not SSH into containers
- Do not manually modify ECS tasks
- Do not deploy outside the pipeline

All changes should flow through CI/CD.