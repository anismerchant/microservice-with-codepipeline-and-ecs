# Data Flow

This document describes how data and control flow through the CI/CD system, from code change to live traffic.

## CI/CD Execution Flow

```
1. Developer pushes code
2. GitHub webhook triggers pipeline
3. CodePipeline starts execution
4. CodeBuild builds application
5. Docker image pushed to ECR
6. ECS service deploys new task
7. Load Balancer routes traffic
```

## Detailed Flow

### 1. Source Change
- Developer commits and pushes code to GitHub.
- GitHub acts as the event source.

```
Developer --> GitHub
```

### 2. Pipeline Trigger
- GitHub webhook notifies AWS CodePipeline.
- A new pipeline execution begins.

```
GitHub --> CodePipeline
```

### 3. Build Stage
- CodePipeline invokes CodeBuild.
- CodeBuild:
  - Compiles the application
  - Builds a Docker image
  - Tags the image
  - Pushes the image to ECR

```
CodePipeline --> CodeBuild --> ECR
```

### 4. Deployment Stage
- ECS service detects new image.
- A new task revision is created.
- Old tasks are replaced with new ones.

```
ECR --> ECS (Fargate)
```

### 5. Request Flow (Runtime)

```
User Request
|
v
Application Load Balancer
|
v
ECS Task (Spring Boot App)
|
v
HTTP Response
```

## Failure Boundaries

```
Build failure        -> CodeBuild stops pipeline
Image push failure   -> Deployment blocked
Task start failure   -> ECS rolls back
```

Failures are isolated to their stage and do not affect previous successful deployments.