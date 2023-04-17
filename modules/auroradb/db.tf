resource "aws_db_subnet_group" "commonid" {
  name       = "${var.account}-rds-aurora-sng-${var.env}-${var.app}-public"
  subnet_ids = var.subnet_ids
  tags = {
    Name        = "${var.account}-rds-aurora-sng-${var.env}-${var.app}-public"
    Environment = var.env
    System      = var.app
  }
}

resource "aws_security_group" "sg-rds" {
  name        = "${var.account}-sg-rds-aurora-${var.env}-${var.app}"
  description = "Allow MYSQL inbound traffic"
  vpc_id      = var.vpc_id


  dynamic "ingress" {
    for_each = var.grant_dev_db_access ? [1] : []
    content {
      description = "Same vpc access"
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = [var.vpc_ip]
    }
  }

  dynamic "ingress" {
    for_each = var.grant_dev_db_access ? [1] : []
    content {
      description = "Matthew Hetherington (Home IP, Wigan)"
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = ["86.25.91.39/32"]
    }
  }

  dynamic "ingress" {
    for_each = var.grant_dev_db_access ? [1] : []
    content {
      description = "Chris McNeill (Home IP, Bangor, NI)"
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = ["81.101.168.183/32"]
    }
  }

  dynamic "ingress" {
    for_each = var.grant_dev_db_access ? [1] : []
    content {
      description = "PA VPN External IP"
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = ["217.38.8.142/32"]
    }
  }

  ingress {
    description = "crncc-ec2-uat-odp-db-2016 (Public IP)"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["52.19.70.252/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.account}-sg-rds-aurora-${var.env}-${var.app}"
    Environment = var.env
    System      = var.app
  }
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_!%^"
}

resource "aws_secretsmanager_secret" "credentials" {
  name                    = "${var.account}-secret-${var.env}-rds-aurora-mysql-credential-${var.app}"
  recovery_window_in_days = 0
  tags = {
    Name        = "${var.account}-secret-${var.env}-rds-aurora-mysql-credential-${var.app}"
    Environment = var.env
    System      = var.app
  }
}

resource "aws_secretsmanager_secret_version" "credentials" {
  secret_id     = aws_secretsmanager_secret.credentials.id
  secret_string = <<EOF
   {
    "password": "${random_password.password.result}"
   }
EOF
}

## AUROARA RDS CLUSTER

resource "aws_rds_cluster_parameter_group" "default" {
  name        = "${var.account}-rds-aurora-${var.env}-${var.app}-pg"
  family      = "aurora-mysql8.0"
  description = "RDS parameter group"

  parameter {
    name         = "binlog_format"
    value        = "row"
    apply_method = "pending-reboot"
  }
}

resource "aws_rds_cluster" "rds_cluster" {
  cluster_identifier              = "${var.account}-rds-aurora-${var.env}-${var.app}-cluster"
  engine                          = "aurora-mysql"
  engine_version                  = "8.0.mysql_aurora.3.02.2"
  engine_mode                     = "provisioned"
  availability_zones              = var.az_zones
  database_name                   = var.db_name
  master_username                 = "admin"
  master_password                 = random_password.password.result
  backup_retention_period         = var.backup_retention_period
  preferred_maintenance_window    = var.maintenance_window
  preferred_backup_window         = "23:00-00:00"
  storage_encrypted               = true
  skip_final_snapshot             = var.skip_final_snapshot
  db_subnet_group_name            = aws_db_subnet_group.commonid.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.default.name
  enabled_cloudwatch_logs_exports = var.log_types
  vpc_security_group_ids          = [aws_security_group.sg-rds.id]

  serverlessv2_scaling_configuration {
    max_capacity = var.max_capacity
    min_capacity = var.min_capacity
  }

  tags = merge(
    {
      Name             = "${var.account}-rds-aurora-${var.env}-${var.app}"
      Environment      = var.env
      System           = var.app
      aws-backup-daily = true
    },
    var.add_scheduler_tag ? { "instance-scheduler" = "rds-default" } : {},
    var.env == "prod" ? { "aws-backup-daily" = "true" } : {},
    var.env == "prod" ? { "aws-backup-weekly" = "true" } : {},
  )

  lifecycle {
    ignore_changes = [
      availability_zones
    ]
  }
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count               = var.instance_count
  identifier          = "${var.account}-rds-aurora-${var.env}-${var.app}-${count.index + 1}"
  cluster_identifier  = aws_rds_cluster.rds_cluster.id
  instance_class      = var.instance_class
  engine              = aws_rds_cluster.rds_cluster.engine
  engine_version      = aws_rds_cluster.rds_cluster.engine_version
  publicly_accessible = var.publicly_accessible

  tags = {
    Name        = "${var.account}-rds-aurora-${var.env}-${var.app}-${count.index}"
    Environment = var.env
    System      = var.app
  }
}

output "db_instances" {
  value = aws_rds_cluster_instance.cluster_instances.*.id

}