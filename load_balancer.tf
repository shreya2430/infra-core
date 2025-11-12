# Load Balancer Security Group
resource "aws_security_group" "load_balancer" {
  name        = "${var.vpc_name}-load-balancer-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  # Allow HTTP from anywhere (IPv4)
  ingress {
    description = "HTTP from anywhere (IPv4)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP from anywhere (IPv6)
  ingress {
    description      = "HTTP from anywhere (IPv6)"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

  # Allow HTTPS from anywhere (IPv4)
  ingress {
    description = "HTTPS from anywhere (IPv4)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS from anywhere (IPv6)
  ingress {
    description      = "HTTPS from anywhere (IPv6)"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

  # Allow all outbound traffic (IPv4)
  egress {
    description = "Allow all outbound traffic (IPv4)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic (IPv6)
  egress {
    description      = "Allow all outbound traffic (IPv6)"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.vpc_name}-load-balancer-sg"
  }
}

# Target Group for the application
resource "aws_lb_target_group" "app" {
  name     = "${var.vpc_name}-app-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = var.lb_health_check_healthy_threshold
    unhealthy_threshold = var.lb_health_check_unhealthy_threshold
    timeout             = var.lb_health_check_timeout
    interval            = var.lb_health_check_interval
    path                = var.lb_health_check_path
    protocol            = "HTTP"
    matcher             = "200"
  }

  deregistration_delay = var.lb_deregistration_delay

  tags = {
    Name = "${var.vpc_name}-app-target-group"
  }
}

# Application Load Balancer
resource "aws_lb" "app" {
  name               = "${var.vpc_name}-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer.id]
  subnets            = aws_subnet.public[*].id
  ip_address_type    = "dualstack" # ADD THIS LINE - Enables both IPv4 and IPv6

  enable_deletion_protection = false

  tags = {
    Name = "${var.vpc_name}-app-lb"
  }
}

# Listener for HTTP traffic
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# Listener for HTTPS traffic
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.app.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = data.aws_acm_certificate.ssl_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}