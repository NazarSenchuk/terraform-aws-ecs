resource "aws_ecs_capacity_provider" "managed" {
  count  =  var.infrastructure.type == "EC2" ? 1 : 0 
  name    = "${var.general.environment}-${var.general.project}-managed"
  cluster = "${var.general.environment}-${var.general.project}-cluster"

  managed_instances_provider {
    infrastructure_role_arn = aws_iam_role.ecs_infrastructure.arn
    propagate_tags          = "CAPACITY_PROVIDER"

    instance_launch_template {
      ec2_instance_profile_arn = aws_iam_instance_profile.ecs_instance.arn
      monitoring               = "BASIC"

      network_configuration {
        subnets         = var.private_subnets
        security_groups = [var.security_group]
      }

      storage_configuration {
        storage_size_gib = 30
      }

      instance_requirements {
        instance_generations = ["current" ,  "previous"]
        allowed_instance_types = var.infrastructure.ec2_types
         memory_mib {
          min = 1024
        }

        vcpu_count {
          min = 1
        }

      }
    }
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_infrastructure_policy]

  tags = var.general.tags
}

resource "aws_ecs_cluster_capacity_providers" "association" {
  count  =  var.infrastructure.type == "EC2" ? 1 : 0 
  cluster_name = aws_ecs_cluster.cluster.name

  capacity_providers = [aws_ecs_capacity_provider.managed[0].name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.managed[0].name
  }
}