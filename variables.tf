variable "general" {
  description = "General project configuration"
  type = object({
    environment = string
    project     = string
    region      = string
    tags        = optional(map(string), {})
  })
}

variable "infrastructure" {
  description = "Infrastructure configuration"
  type = object({
    type         = string
    fargate_spot = optional(bool, false)
    platform     = optional(string, "X86_64")
    ec2_types    = optional(list(string), [])
  })

  validation {
    condition     = contains(["FARGATE", "EC2"], var.infrastructure.type)
    error_message = "The infrastructure type must be either 'FARGATE' or 'EC2'."
  }
}

variable "services" {
  description = "Deployment configuration for each service"
  type = map(object({
    name          = string
    img           = string
    desired_count = number
    alb_path      = string
    health_check  = optional(string, "/")
    blue_green    = optional(bool, false)
    target_port   = optional(number, 80)
    spot_percent  = optional(number, 40)
    requirements = optional(object({
      cpu    = optional(number, 256)
      memory = optional(number, 512)
    }), {
      cpu    = 256
      memory = 512
    })

    deploy = object({
      enabled   = bool
      strategy  = string
      bake_time = optional(number, 5)
    })

    autoscaling = object({
      enabled            = bool
      min                = number
      max                = number
      metric             = optional(string, "CPUUtilization")
      metric_target      = optional(number, 70)
      scale_in_cooldown  = optional(number, 300)
      scale_out_cooldown = optional(number, 300)
    })
  }))

  validation {
    condition = alltrue([
      for service in var.services : contains(["BLUE_GREEN", "ROLLING"], service.deploy.strategy)
    ])
    error_message = "Deployment strategy must be one of: BLUE_GREEN, ROLLING."
  }
}

variable "cicd" {
  description = "CI/CD pipeline configuration"
  type = object({
    github              = optional(bool, false)
    github_organization = optional(string, "")
    registry            = optional(string, "ecr")
    registry_region     = optional(string, "")
  })
}