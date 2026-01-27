resource "aws_ecs_task_definition" "tasks" {
  for_each = var.services
  family = "${var.general.environment}-${var.general.project}-${each.key}" 
  network_mode  = "awsvpc"
  container_definitions = jsonencode([{
    name      = each.key,
    image     = each.value.img ,
    essential = true,
    portMappings = [
      {
        name          = "http-port"
        containerPort = each.value.target_port
        hostPort      = each.value.target_port
      }
    ],

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.cluster.name
        awslogs-stream-prefix = "ecs"
        awslogs-region        = var.general.region
      }
    }
  }])
  requires_compatibilities = [var.infrastructure.type]
  cpu                      = each.value.requirements.cpu
  memory                   = each.value.requirements.memory
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = var.infrastructure.platform
  }
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  
  tags = var.general.tags
}