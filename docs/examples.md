# Usage Examples

This document provides various configuration examples for the ECS infrastructure.

## 1. Minimal Fargate Configuration

Deploying a single service using Fargate is the simplest way to get started.

```hcl
general = {
  environment = "prod"
  project     = "myapp"
  region      = "us-east-1"
}

infrastructure = {
  type = "FARGATE"
}

services = {
  web = {
    name          = "web-server"
    img           = "nginx:latest"
    desired_count = 2
    alb_path      = "/*"
    target_port   = 80
    
    deploy = {
      enabled  = true
      strategy = "REPLICA"
    }

    autoscaling = {
      enabled = true
      min     = 2
      max     = 5
    }
  }
}
```

## 2. EC2 Optimized Cluster

For workloads requiring specific instance types or cost optimization using Reserved Instances/Savings Plans.

```hcl
infrastructure = {
  type      = "EC2"
  ec2_types = ["t3.medium", "c5.large"]
}

services = {
  api = {
    name          = "api-service"
    img           = "my-repo/api:v1.2.0"
    desired_count = 3
    alb_path      = "/api/*"
    target_port   = 8080
    
    requirements = {
      cpu    = 512
      memory = 1024
    }

    deploy = {
      enabled  = true
      strategy = "REPLICA"
    }

    autoscaling = {
      enabled       = true
      min           = 2
      max           = 10
      metric_target = 60 # Scale when CPU hits 60%
    }
  }
}
```

## 3. Blue/Green Deployment Strategy

To use Blue/Green deployments, ensure your `deploy.strategy` is set to `BLUE_GREEN`. The module will automatically create the necessary target groups.

```hcl
services = {
  frontend = {
    name          = "frontend"
    img           = "my-repo/frontend:latest"
    desired_count = 2
    alb_path      = "/*"
    target_port   = 3000
    
    deploy = {
      enabled   = true
      strategy  = "BLUE_GREEN"
      bake_time = 10 # Wait 10 minutes before terminating old version
    }

    autoscaling = {
      enabled = false
      min     = 2
      max     = 2
    }
  }
}
```

## 4. Multiple Services with Service Connect

The module enables **Service Connect** by default. Services can talk to each other using their service name.

If you have a `frontend` service and an `api` service, the frontend can reach the api at `http://api:3001` (if `target_port` for api is 3001).
