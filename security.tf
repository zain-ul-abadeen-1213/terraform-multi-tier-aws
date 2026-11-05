# Security groups are chained: internet -> ALB -> app tier -> database tier.
# Each tier only accepts traffic from the tier in front of it.

resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Application Load Balancer - HTTP from the internet"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-alb-sg" }
}

resource "aws_security_group" "app" {
  name        = "${var.project_name}-app-sg"
  description = "Application tier - HTTP only from the load balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from the ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-app-sg" }
}

resource "aws_security_group" "db" {
  name        = "${var.project_name}-db-sg"
  description = "Database tier - MySQL only from the application tier"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL from the app tier"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-db-sg" }
}
