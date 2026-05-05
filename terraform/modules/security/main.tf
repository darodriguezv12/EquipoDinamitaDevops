resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-alb-sg"
  description = "Allow HTTP access from the internet to the ALB."
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-alb-sg"
  }
}

resource "aws_security_group" "ecs" {
  name        = "${var.name_prefix}-ecs-sg"
  description = "Allow traffic from ALB to Fargate tasks and outbound to RDS/internet."
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-ecs-sg"
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.name_prefix}-rds-sg"
  description = "Allow PostgreSQL only from Fargate tasks."
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-rds-sg"
  }
}

resource "aws_security_group_rule" "alb_http_ingress" {
  type              = "ingress"
  description       = "HTTP from internet"
  security_group_id = aws_security_group.alb.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_to_ecs_egress" {
  type                     = "egress"
  description              = "HTTP to ECS tasks"
  security_group_id        = aws_security_group.alb.id
  from_port                = var.app_port
  to_port                  = var.app_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs.id
}

resource "aws_security_group_rule" "ecs_from_alb_ingress" {
  type                     = "ingress"
  description              = "Application traffic from ALB"
  security_group_id        = aws_security_group.ecs.id
  from_port                = var.app_port
  to_port                  = var.app_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "ecs_to_rds_egress" {
  type                     = "egress"
  description              = "PostgreSQL to RDS"
  security_group_id        = aws_security_group.ecs.id
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds.id
}

resource "aws_security_group_rule" "ecs_https_egress" {
  type              = "egress"
  description       = "HTTPS for ECR, CloudWatch Logs and AWS APIs without NAT Gateway"
  security_group_id = aws_security_group.ecs.id
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "rds_from_ecs_ingress" {
  type                     = "ingress"
  description              = "PostgreSQL from ECS tasks"
  security_group_id        = aws_security_group.rds.id
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs.id
}
