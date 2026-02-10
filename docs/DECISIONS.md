# Architectural Decisions

This document records key technical decisions and their rationale.

## Container Orchestration: Amazon ECS (Fargate)

**Decision**  
Use Amazon ECS with Fargate instead of EC2-based ECS or Kubernetes.

**Why**
- No server management
- Native AWS integration
- Lower operational complexity
- Suitable for small to medium workloads

## CI/CD Orchestration: AWS CodePipeline

**Decision**  
Use AWS CodePipeline as the primary CI/CD orchestrator.

**Why**
- Native integration with GitHub
- Managed service
- Clear separation of pipeline stages

## Build System: AWS CodeBuild

**Decision**  
Use CodeBuild for compiling and containerizing the application.

**Why**
- Fully managed build environment
- Native Docker support
- Integrates directly with ECR and CodePipeline

## Container Registry: Amazon ECR

**Decision**  
Use Amazon Elastic Container Registry for Docker images.

**Why**
- Tight IAM integration
- Low latency access for ECS
- No external registry dependency

## Deployment Strategy: ECS Rolling Update

**Decision**  
Use rolling deployments instead of blue/green.

**Why**
- Simpler setup
- Fewer moving parts
- Adequate for stateless applications

## Infrastructure as Code: Terraform

**Decision**  
Use Terraform to provision AWS resources.

**Why**
- Declarative infrastructure
- Version-controlled changes
- Clear dependency graph