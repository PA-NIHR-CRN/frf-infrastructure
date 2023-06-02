

resource "aws_lb" "lb" {
  name               = "${var.account}-lb-${var.env}-${var.system}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg-ecs.id]
  subnets            = var.ecs_subnets

  enable_deletion_protection = true

  access_logs {
    bucket  = var.logs_bucket
    enabled = true
  }

  tags = {
    Name        = "${var.account}-lb-${var.env}-${var.system}"
    Environment = var.env
    System      = var.system
  }
}

resource "aws_lb_target_group" "lb-targetgroup" {
  name                 = "${var.account}-lb-${var.env}-${var.system}-targetgroup"
  port                 = 3000
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = var.vpc_id
  deregistration_delay = 30

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/api/health"
    port                = "traffic-port"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = 200
  }

  tags = {
    Name        = "${var.account}-lb-${var.env}-${var.system}-targetgroup"
    Environment = var.env
    System      = var.system
  }
}

resource "aws_lb_listener" "lb-listener-" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "3000"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb-targetgroup.arn
  }
}


output "lb_dns" {
  value = aws_lb.lb.dns_name

}

output "lb_arn" {
  value = aws_lb.lb.id
  
}