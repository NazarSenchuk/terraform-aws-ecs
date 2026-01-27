# AWS ECS Infrastructure with Terraform

This project provides a robust, modular, and scalable Terraform configuration to deploy containerized applications on AWS ECS. It supports both **EC2** and **Fargate** launch types, integrated with Application Load Balancer (ALB), Blue/Green deployments, and Service Connect.

##  Features

- **Multi-Service Architecture**: Easily manage multiple services within a single ECS cluster.
- **Flexible Infrastructure**: Switch between EC2 and Fargate by changing a single variable.
- **Advanced Networking**: Automated VPC, public/private subnets, and security group management.
- **Blue/Green Deployments**: Built-in support for ECS native Blue/Green deployment strategy.
- **Service Connect**: Internal service-to-service communication using Service Connect.
- **Autoscaling**: Target tracking scaling based on CPU or memory metrics.
- **Security First**: Granular IAM roles and least-privileged security groups.



```text
├── main.tf              # Logic and module orchestration
├── variables.tf         # Input variable definitions
├── outputs.tf           # Output definitions
├── versions.tf          # Terraform and provider version constraints
├── examples/            # Usage examples
└── modules/             # Sub-modules (networking, loadbalancing, ecs, cicd)
```

## 🛠 Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (v1.5+)
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- Docker (for building/pushing images to ECR)

##  Usage

The simplest way to use this module:

```hcl
module "ecs_cluster" {
  source  = "NazarSenchuk/awsecs/aws" # Replace with registry path or github source
  version = "1.0.0"

  general = {
    environment = "dev"
    project     = "my-app"
    region      = "us-east-1"
  }

  infrastructure = {
    type = "FARGATE"
  }

  services = {
    api = {
      name          = "web-service"
      img           = "nginx:latest"
      desired_count = 1
      alb_path      = "/*"
      deploy = {
        enabled  = true
        strategy = "ROLLING"
      }
      autoscaling = {
        enabled = false
        min     = 1
        max     = 2
      }
    }
  }

}
```

##  Quick Start

1. **Initialize Terraform:**
   ```bash
   terraform init
   ```

2. **Review Plan:**
   ```bash
   terraform plan -var-file="demo.tfvars"
   ```

3. **Deploy:**
   ```bash
   terraform apply -var-file="demo.tfvars"
   ```

##  Configuration

All available configuration options, including optional parameters and defaults, are documented in detail in:
 **[attributes.tfvars](./attributes.tfvars)**

## Full Example: Build, Push & Deploy

To deploy the provided example applications (Frontend & Backend), follow these steps:

### 1. Build and Push Images
```bash
# 1. Build local docker images
cd example/
./build.sh

# 2. Push to your ECR registry (replace with your ECR URL and region)
./push.sh 123456789012.dkr.ecr.eu-central-1.amazonaws.com eu-central-1
```

### 2. Update Configuration
Update your `example.tfvars` (or `attributes.tfvars`) with the correct image URIs from your ECR registry.

### 3. Deploy Infrastructure
```bash
cd ..
terraform init
terraform apply -var-file="example.tfvars"
```

##  Documentation
- [Example Configurations](./docs/examples.md)
- [Deployment Recommendations](./docs/recommendations.md)
- [Known Issues & Bugs](./docs/bugs.md)
