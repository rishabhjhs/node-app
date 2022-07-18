module "vpc" {
  source = "../infra/modules/vpc"

  vpc_cidr_block = var.vpc_cidr_block
  public_subnet_cidr_blocks = var.public_subnet_cidr_blocks 
}

resource "aws_ecr_repository" "app_repository" {
  name                 = "app-repository"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecs_cluster" "app_cluster" {
  name = "cluster-${var.env}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "app_task_defination" {
  count = var.release_version != "" ? 1 : 0
  family = "app_task_defination"
  execution_role_arn = aws_iam_role.app_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = "web"
      image     = "${aws_ecr_repository.app_repository.repository_url}:${var.release_version}"
      essential = true

      portMappings = [
        {
          containerPort = 3000
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
          options = {
            awslogs-create-group =  "true",
            awslogs-group         = "app-logs"
            awslogs-stream-prefix = "ecs"
            awslogs-region        = var.region
          }
        }
    }
  ])

  requires_compatibilities = [
    "FARGATE"
  ]

  network_mode = "awsvpc"
  cpu          = "256"
  memory       = "512"
}

resource "aws_ecs_service" "app_service" {
  count = var.release_version != "" ? 1 : 0
  name            = "app_service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task_defination[0].arn
  desired_count   = 2
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.app_lb_tg.arn
    container_name   = jsondecode(aws_ecs_task_definition.app_task_defination[0].container_definitions)[0].name
    container_port   = 3000
  }

  network_configuration {
    subnets          = module.vpc.subnet_ids
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_container.id]
  }
}

resource "aws_security_group" "ecs_container" {
  name        = "ecs-container"
  description = "Allow http inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "HTTP from app load balancer"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.allow_http_lb.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ecs-container"
  }
}
