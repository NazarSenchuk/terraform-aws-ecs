resource "aws_lb" "main" {
  name               = "${var.general.project}-${var.general.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnets
  security_groups = [var.security_group]
  enable_deletion_protection = false
  tags = var.general.tags
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response content"
      status_code  = "200"
    }
  }
}



resource "aws_lb_listener_rule" "services" {
  for_each = { for svc_name, svc in var.services : svc_name => svc }

  listener_arn = aws_lb_listener.main.arn
  priority     = index(keys(var.services), each.key) + 10

  action {
    type             = "forward"
    
    forward {
      target_group {
        arn  = each.value.deploy.strategy == "BLUE_GREEN" ?  aws_lb_target_group.groups["${each.key}-blue"].arn : aws_lb_target_group.groups["${each.key}-common"].arn
        weight = 100 
      }
      
      dynamic "target_group"{
        for_each =  each.value.deploy.strategy == "BLUE_GREEN" ? [1] : []
        content {
            arn  =  aws_lb_target_group.groups["${each.key}-green"].arn
            weight = 0
        }
      } 
    }
  }

  lifecycle {
    ignore_changes = [action]
  }

  condition {
    # Path-based routing
    path_pattern {
      values = [each.value.alb_path]
    }
  }

  

}

locals {
  target_groups = flatten([
    for svc_name, svc in var.services : [
      for role in (svc.deploy.strategy == "BLUE_GREEN" ? ["blue", "green"] : ["common"]) : {
        health_check = svc.health_check
        service_name = svc_name
        role         = role
        tg_name      = role == "common" ? "${svc_name}-common" : "${svc_name}-${role}"
      }
    ]
  ])
}

resource "aws_lb_target_group" "groups" {
  for_each = { for tg in local.target_groups : tg.tg_name => tg }

  name     = each.value.tg_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc
  target_type = "ip"
  health_check {
    path =  each.value.health_check
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = {
    Service  = each.value.service_name
    Role     = each.value.role
    Environment  = var.general.environment
  }
}
