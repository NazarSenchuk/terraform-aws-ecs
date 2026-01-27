resource "aws_cloudwatch_log_group" "cluster" {
  name = "${var.general.environment}-${var.general.project}-cluster"
  tags = var.general.tags
}

resource "aws_ecs_cluster" "cluster" {
  name = "${var.general.environment}-${var.general.project}-cluster"
  configuration {
    execute_command_configuration {
      logging    = "OVERRIDE"
      log_configuration {
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.cluster.name
      }
    }
  }

  tags = var.general.tags
}