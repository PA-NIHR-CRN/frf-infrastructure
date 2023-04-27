resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${var.account}-ecs-${var.env}-${var.system}-cluster"

  tags = {
    Name        = "${var.account}-ecs-${var.env}-${var.system}-cluster",
    Environment = var.env,
    System      = var.system,
  }
}

resource "aws_cloudwatch_log_group" "ecs-cloudwatchloggroup" {
  name = "${var.account}-ecs-${var.env}-${var.system}-loggroup"

  tags = {
    Name        = "${var.account}-ecs-cloudwatch-${var.env}-${var.system}-loggroup",
    Environment = var.env,
    System      = var.system,
  }
}


resource "aws_ecs_task_definition" "ecs-task-definition" {
  family                   = "${var.account}-ecs-${var.env}-${var.system}-task-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 4096
  execution_role_arn       = aws_iam_role.iam-ecs-task-role.arn
  task_role_arn            = aws_iam_role.iam-ecs-task-role.arn
  container_definitions = jsonencode([{
    name      = var.container_name
    image     = var.image_url
    essential = true
    portMappings = [{
      protocol      = "tcp"
      containerPort = 8080
      hostPort      = 8080
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs-cloudwatchloggroup.id
        awslogs-region        = "eu-west-2"
        awslogs-stream-prefix = "ecs"
      }
    }
    environment = [
      { "name" : "dummy_env", "value" : "1" },
    ]
  }])
  tags = {
    Name        = "${var.account}-ecs-${var.env}-${var.system}-task-definition",
    Environment = var.env,
    System      = var.system,
  }
}

resource "aws_security_group" "sg-ecs" {
  name        = "${var.account}-sg-${var.env}-ecs-${var.system}"
  description = "Allow HTTP inbound traffic for API gateway and Kafka connection"
  vpc_id      = var.vpc_id

  ingress {
    description      = "container-port"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.account}-sg-${var.env}-ecs-${var.system}",
    Environment = var.env,
    System      = var.system,
  }
}

resource "aws_ecs_service" "ecs_service" {
  name            = "${var.account}-ecs-service-${var.env}-${var.system}"
  cluster         = aws_ecs_cluster.ecs-cluster.id
  task_definition = aws_ecs_task_definition.ecs-task-definition.arn
  desired_count   = var.instance_count
  network_configuration {
    security_groups  = [aws_security_group.sg-ecs.id]
    subnets          = var.ecs_subnets
    assign_public_ip = false
  }
  launch_type = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.lb-targetgroup.arn
    container_name   = var.container_name
    container_port   = 80
  }
  # health_check_grace_period_seconds = 30

  tags = {
    Name        = "${var.account}-ecs-service-${var.env}-${var.system}",
    Environment = var.env,
    System      = var.system,
  }
}

output "ecs_sg" {
  value = aws_security_group.sg-ecs.id
}