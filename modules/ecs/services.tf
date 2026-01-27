resource "aws_service_discovery_http_namespace" "app" {
  name = "cluster.internal"
}


resource "aws_ecs_service" "services" {
  for_each = var.services
  name            = each.key
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.tasks[each.key].arn
  desired_count   = each.value.desired_count

  depends_on      = [aws_iam_role_policy_attachment.ecs_service_attachment]
  force_new_deployment = true

  network_configuration {
    subnets = var.private_subnets
    assign_public_ip = false    
    security_groups = [var.security_group]
  }


  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.app.arn

    service {
      discovery_name = each.key
      port_name      = "http-port"
      client_alias {
        port     = each.value.target_port
        dns_name = each.key
      }
    }
  }

  deployment_controller {
    type = "ECS"
  }
  deployment_configuration {
    strategy = each.value.deploy.strategy

    bake_time_in_minutes = each.value.deploy.bake_time
  }

  capacity_provider_strategy { 
    weight = var.infrastructure.type == "FARGATE"? 100 - each.value.spot_percent : 100
    capacity_provider = var.infrastructure.type == "EC2"? aws_ecs_capacity_provider.managed[0].name : "FARGATE"

  }

  dynamic "capacity_provider_strategy" { 
    for_each = var.infrastructure.type == "FARGATE" && var.infrastructure.fargate_spot == true ? [1] : [0]
    content   {
    weight = each.value.spot_percent
    capacity_provider = "FARGATE_SPOT"
    }
  }
  
  

  load_balancer {
    target_group_arn = each.value.deploy.strategy == "BLUE_GREEN" ? var.target_groups["${each.key}-blue"].arn : var.target_groups["${each.key}-common"].arn
    container_name   = each.key
    container_port   = each.value.target_port

    dynamic "advanced_configuration" {
      for_each = each.value.deploy.strategy == "BLUE_GREEN" ? [1] : []
      content {
        alternate_target_group_arn = var.target_groups["${each.key}-green"].arn
        production_listener_rule   = var.listener_rules[each.key].arn
        role_arn                   = aws_iam_role.ecs_service_role.arn
      }
    }
  }


  tags = var.general.tags
}


resource "aws_appautoscaling_target" "ecs_target" {
  for_each = {for k , v  in var.services  : k => v if v.autoscaling.enabled} 
  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount" 
  resource_id        = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.services[each.key].name}"
  min_capacity       = each.value.autoscaling.min
  max_capacity       = each.value.autoscaling.max
}

resource "aws_appautoscaling_policy" "cpu_utilization_policy" {
  for_each = {for k , v  in var.services  : k => v if v.autoscaling.enabled} 
  name               = "cpu-utilization-policy"
  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"
  resource_id        = aws_appautoscaling_target.ecs_target[each.key].resource_id
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization" 
    }

    target_value = each.value.autoscaling.metric_target

    scale_in_cooldown  =  each.value.autoscaling.scale_in_cooldown
    scale_out_cooldown = each.value.autoscaling.scale_out_cooldown
  }
}