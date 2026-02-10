# Runbook

This document describes how to operate, deploy, and troubleshoot the CI/CD system.

## Normal Operation

### Trigger a Deployment
- Push code to the GitHub repository.
- CodePipeline triggers automatically.
- No manual intervention required.

## Verify Deployment

### Check Pipeline
- AWS Console → CodePipeline
- Ensure all stages are green

### Check Build
- AWS Console → CodeBuild
- Verify build logs
- Confirm Docker image pushed to ECR

### Check Runtime
- AWS Console → ECS → Cluster → Service
- Ensure desired tasks == running tasks

## Common Failures

### Build Failure
**Symptoms**
- Pipeline stops at Build stage

**Actions**
- Inspect CodeBuild logs
- Fix Dockerfile or buildspec.yml
- Push new commit

### Image Pull Failure
**Symptoms**
- ECS tasks fail to start

**Actions**
- Verify ECR image exists
- Check task execution IAM role
- Confirm image URI is correct

### Application Not Reachable
**Symptoms**
- Load balancer returns 5xx or timeout

**Actions**
- Check ECS task health
- Verify container port mapping
- Check security group inbound rules

## Rollback
- Re-run pipeline using last successful commit
- ECS will redeploy previous task revision