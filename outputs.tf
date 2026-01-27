output "url" {
  value       = "http://${module.loadbalancing.url}"
  description = "The main entry point URL for the Load Balancer"
}

output "vpc_id" {
    value = module.networking.vpc_id
    description = "ID of the VPC"
}

output "public_subnets" {
    value = module.networking.public_subnets
    description = "Public subnets"
}

output "private_subnets" {
    value = module.networking.private_subnets
    description = "Private subnets"
}

output "alb_security_group" {
    value = module.networking.alb_security_group
    description = "Security group for ALB"
}

output "ecs_security_group" {
    value = module.networking.ecs_security_group
    description = "Security group for ECS"
}