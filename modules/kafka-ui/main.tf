resource "aws_ecs_cluster" "nsip-ecs-cluster" {
  name = "${var.account}-ecs-${var.env}-${var.system}-kafka-ui-cluster"

  tags = {
    Name        = "${var.account}-ecs-${var.env}-${var.system}-kafka-ui-cluster",
    Environment = var.env,
    System      = var.system,
  }
}

resource "aws_cloudwatch_log_group" "nsip-ecs-cloudwatchloggroup" {
  name = "${var.account}-ecs-${var.env}-nsip-kafka-ui-loggroup"

  tags = {
    Name        = "${var.account}-ecs-cloudwatch-${var.env}-nsip-kafka-ui-loggroup",
    Environment = var.env,
    System      = "nsip",
  }
}


resource "aws_ecs_task_definition" "nsip-ecs-task-definition" {
  family                   = "${var.account}-ecs-${var.env}-nsip-kafka-ui-task-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 4096
  execution_role_arn       = aws_iam_role.nsip-iam-ecs-task-role.arn
  task_role_arn            = aws_iam_role.nsip-iam-ecs-task-role.arn
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
        awslogs-group         = aws_cloudwatch_log_group.nsip-ecs-cloudwatchloggroup.id
        awslogs-region        = "eu-west-2"
        awslogs-stream-prefix = "ecs"
      }
    }
    environment = [
      { "name" : "KAFKA_CLUSTERS_0_NAME", "value" : "nsip-${var.env}" },
      { "name" : "KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS", "value" : "${var.bootstrap_servers}" },
      { "name" : "KAFKA_CLUSTERS_0_ZOOKEEPER", "value" : "${var.zookeeper_connection_string}" },
    ]
  }])
  tags = {
    Name        = "${var.account}-ecs-${var.env}-nsip-kafka-ui-task-definition",
    Environment = var.env,
    System      = "nsip",
  }
}

resource "aws_security_group" "sg-ecs" {
  name        = "${var.account}-sg-${var.env}-nsip-ecs-kafka-ui"
  description = "Allow HTTP inbound traffic for API gateway and Kafka connection"
  vpc_id      = var.vpc_id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

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
    Name        = "${var.account}-sg-${var.env}-nsip-ecs-kafka-ui",
    Environment = var.env,
    System      = "nsip",
  }
}

resource "aws_ecs_service" "nsip_ecs_service" {
  name            = "${var.account}-ecs-service-${var.env}-nsip-kafka-ui"
  cluster         = aws_ecs_cluster.nsip-ecs-cluster.id
  task_definition = aws_ecs_task_definition.nsip-ecs-task-definition.arn
  desired_count   = 1
  network_configuration {
    security_groups  = [aws_security_group.sg-ecs.id]
    subnets          = var.ecs_subnets
    assign_public_ip = false
  }
  launch_type = "FARGATE"
  # health_check_grace_period_seconds = 30

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = var.container_name
    container_port   = 8080
  }

  tags = {
    Name        = "${var.account}-ecs-service-${var.env}-nsip-kafka-ui",
    Environment = var.env,
    System      = "nsip",
  }
  # workaround for https://github.com/hashicorp/terraform/issues/12634
  depends_on = [aws_lb_listener.tcp]

  # [after initial apply] don't override changes made to task_definition
  # from outside of terrraform (i.e.; fargate cli)
  lifecycle {
    ignore_changes = [task_definition]
  }
}

output "ecs_sg" {
  value = aws_security_group.sg-ecs.id
}