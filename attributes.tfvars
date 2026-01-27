################################################################################
# General Project Configuration
################################################################################
general = {
  # The deployment environment (e.g., dev, staging, prod)
  environment = "dev"

  # Name of the project, used for resource naming and tagging
  project = "myproj"

  # AWS region where resources will be deployed
  region = "eu-central-1"

  # (Optional) Additional tags to apply to all taggable resources
  # Default: {}
  tags = {
    Owner       = "DevOps"
    ManagedBy   = "Terraform"
  }
}

################################################################################
# Infrastructure Configuration
################################################################################
infrastructure = {
  # Type of capacity provider: "FARGATE" or "EC2"
  type = "FARGATE"

  # (Optional) Use Fargate Spot for cost savings. Only applies if type is "FARGATE".
  # Default: false
  fargate_spot = true

  # (Optional) CPU architecture for the ECS tasks: "X86_64" or "ARM64"
  # Default: "X86_64"
  platform = "X86_64"

  # (Optional) List of EC2 instance types to use. Only applies if type is "EC2".
  # Default: []
  ec2_types = ["c7i-flex.large"]
}

################################################################################
# Services Configuration (Map of services)
################################################################################
services = {
  # Key is the service identifier
  frontend = {
    # Name of the service in ECS
    name = "frontend"

    # Full container image URL (typically from ECR)
    img = "649636402385.dkr.ecr.us-east-1.amazonaws.com/frontend:latest"

    # Number of initial tasks to run
    desired_count = 2

    # Path pattern for ALB routing (e.g., "/*", "/api/*")
    alb_path = "/*"

    # (Optional) Health check path for the ALB target group
    # Default: "/"
    health_check = "/"

    # (Optional) Enable/disable blue-green deployment logic (CodeDeploy)
    # Default: false
    blue_green = true

    # (Optional) Port the container listens on
    # Default: 80
    target_port = 3000

    # (Optional) Percentage of tasks to run on Fargate Spot vs On-Demand
    # Default: 40
    spot_percent = 40

    # (Optional) Resource requirements for the task
    requirements = {
      # CPU units: 256 (.25 vCPU), 512 (.5 vCPU), 1024 (1 vCPU), etc.
      # Default: 256
      cpu = 256
      # Memory in MB
      # Default: 512
      memory = 512
    }

    # Deployment configuration
    deploy = {
      # Whether to manage deployment via this configuration
      enabled = true

      # Strategy: "BLUE_GREEN" (using CodeDeploy) or "ROLLING" (standard ECS)
      strategy = "BLUE_GREEN"

      # (Optional) Time in minutes to wait before terminating the old task set (for Blue/Green)
      # Default: 5
      bake_time = 1
    }

    # Auto-scaling configuration
    autoscaling = {
      # Whether auto-scaling is enabled for this service
      enabled = true

      # Minimum number of tasks
      min = 1

      # Maximum number of tasks
      max = 10

      # (Optional) Metric to scale on: "CPUUtilization" or "MemoryUtilization"
      # Default: "CPUUtilization"
      metric = "CPUUtilization"

      # (Optional) Target value for the metric (percent)
      # Default: 70
      metric_target = 70

      # (Optional) Cooldown period in seconds after a scale-in action
      # Default: 300
      scale_in_cooldown = 300

      # (Optional) Cooldown period in seconds after a scale-out action
      # Default: 300
      scale_out_cooldown = 300
    }
  }
}

################################################################################
# CI/CD Configuration
################################################################################
# It will generate actions workflows for GitHub in ./modules/cicd/generated/
cicd = {
  # Whether to enable GitHub integration for the pipeline
  github = true

  # GitHub organization or username owning the repository
  github_organization = "NazarSenchuk"

  # URL of the ECR registry (without the repository name)
  registry = "649636402385.dkr.ecr.us-east-1.amazonaws.com"

  # Region where the ECR registry resides
  registry_region = "us-east-1"
}
