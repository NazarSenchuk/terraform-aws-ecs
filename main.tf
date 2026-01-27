module "networking" {
    source = "./modules/networking"
    general = var.general
}

module "loadbalancing" {
    source = "./modules/loadbalancing"
    general = var.general
    services = var.services
    public_subnets = module.networking.public_subnets
    vpc  =  module.networking.vpc_id
    security_group = module.networking.alb_security_group
}

module "ecs" {
    source  = "./modules/ecs"
    general = var.general
    infrastructure  = var.infrastructure
    services =  var.services
    target_groups  = module.loadbalancing.target_groups
    listener_rules = module.loadbalancing.listener_rules
    security_group = module.networking.ecs_security_group
    private_subnets = module.networking.private_subnets
}



module "cicd" {
    source  = "./modules/cicd"
    general = var.general
    services =  var.services
    cicd   =    var.cicd
    cluster_name  = "${var.general.environment}-${var.general.project}-cluster"
    
}