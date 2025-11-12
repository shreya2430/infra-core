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

# Application Load Balancer (IPv4 only)
resource "aws_lb" "app" {
  name               = "${var.vpc_name}-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer.id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = false

  tags = {
    Name = "${var.vpc_name}-app-lb"
  }
}

# Listener for HTTPS traffic only
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

# Optional: HTTP listener that redirects to HTTPS
resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}