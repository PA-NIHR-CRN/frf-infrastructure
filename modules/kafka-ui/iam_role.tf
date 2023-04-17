resource "aws_iam_role" "nsip-iam-ecs-task-role" {
  name = "${var.account}-iam-${var.env}-nsip-ecs-iam-role"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
  tags = {
    Name        = "${var.account}-iam-${var.env}-nsip-ecs-iam-role",
    Environment = var.env,
    System      = "nsip",
  }
}

resource "aws_iam_role_policy" "nsip-task-execution-role-policy" {
  name = "${var.account}-iam-policy-${var.env}-nsip-ecs-task-definition"
  role = aws_iam_role.nsip-iam-ecs-task-role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Action" : [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "lambda:InvokeFunction",
          "sqs:ReceiveMessage",
          "kafka:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
