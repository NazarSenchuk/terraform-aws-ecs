module "ecs_cluster" {
  source = "../../"

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
      name          = "api-service"
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
