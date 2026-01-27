output "vpc_id" {
    value = module.vpc.vpc_id
}

output "public_subnets" {
    value = module.vpc.public_subnets
}

output "private_subnets" {
    value = module.vpc.private_subnets
}

output "alb_security_group" {
    value = aws_security_group.alb.id
}

output "ecs_security_group" {
    value = aws_security_group.ecs_internal_all.id
}